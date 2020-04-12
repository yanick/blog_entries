created: 2020-04-12
tags:
    - typescript
---

# Tales of the Typescrypt: Recasting the first stone

For typical stuff, Typescript typing is pretty magical.
But when one gets meta on the typing system, it can get tricky real fast.

Having swam for so long in the interpreted world where it's never too late
to transmutate stuff, Typescript forces me to 
pay special attention to what is done at compile-time versus runtime. 
Crueller still, it puts me in positions where I *can't* have my cake and eat
it too. I can either have ridiculously polymorphic functions with implicit
behaviors and succinct code shorthands, OR I can write things more explicitly,
more rigidly, with much better typed results. You won't believe the agony this
puts me through.

All that to say, this blog entry documents one of those hard corner cases.
Spoiler: there is not going to be a neat solution at the end. But that's fine,
as the goal is more to walk you through the whole experience, and give you a
taste of how thinking in Typescript differs from a vanilla JavaScript mindset.

## The deed to be done

I am working on a library abstracting some of the boilerplate of Redux. I will
spare you the details as this is another, incredibly large, kettle of fish by
its own right. Suffice to say that I am building an api object that is
destined to be a [duck]()-like one-stop-shop for the Redux store -- actions,
reducer, middleware, selectors, etc.

For the good of this blog entry, we'll simplify that api down to just building actions,
forgetting about recursivity and everything else. Which leaves us with code
looking like this:

```
type Dictionary<T> = { [key: string]: T };

type DuxConfig = {
    actions?: Dictionary<Function>
}

class Dux {
    private localActions: Dictionary<Function>;

    constructor(config: DuxConfig = {}){
        this.localActions = config.actions ?? {};
    }

    addAction(name: string, creator: Function) {
        this.localActions[name] = creator;
    }

    get actions() {
        return this.localActions;
    }
}
```

That's perfectly cromulent code that works. So... what more do I want? 

Well, it's working all right, but if you ask Typescript to tell you what's
the type of the `actions` getter, it'll say it's a dictionary of functions.
Which is absolutly true, and mildly useful. But you know what would be 
niftier? If it could instead 
gives me a more precise type specifying exactly which actions the object 
supports.

## Solution #1 (aka the sane one)

If we could tinker with types at runtime, there will be no problem. We could
gather information as we go along. As it is, the type of the class has
to be set at compile time. So we'll have to set some restrictions
to how we use the class: if the consumer of the class wants the actions
to be discoverable via their types, they'll have to be declared as part
of the class initialization.

```
type ActionsOf<D> = D extends { actions: infer A } ? A : never;

class Dux<C extends DuxConfig> {
    private localActions: Dictionary<Function>;

    constructor(config: C){
        this.localActions = config.actions ?? {};
    }

    addAction(name: string, creator: Function) {
        this.localActions[name] = creator;
    }

    get actions(): ActionsOf<C> {
        return this.localActions as ActionsOf<C>;
    }
}
```

And boom! It's already much better. With this we can create a dux like so:

```
const myDux = new Dux({
    actions: {
        doThis: () => {},
        doThat: () => {},
    }});
```

and TypeScript will now know that the actions are `doThis` and `doThat`.
Sweet. 

Also, it's worth nothing that with this implementation it's still possible
to add actions programatically via `addAction`. It'll just not reflect 
into the type.

```
// assuming the myDux object of the previous example

myDux.actions.doThis();  // known by TypeScript and blissfully completed

myDux.addAction( 'doSomethingElse', () => {} );

(myDux.actions as any).doSomethingElse(); // casting required so that TS
                                          // doesn't throw a fit
```

If the class's consumer expects to use `addAction` a lot and doesn't want 
to `as any` all over the place, there's an easy emergency latch for that:


```
const myDux = new Dux({
    actions: {
        doThis: () => {},
        doThat: () => {},
    } as Dictionary<Function>
});
```

and hop! `myDux.actions` is back to being a generic Dictionary.

## Solution #2, where things go experimental

The previous solution is the one I'm using right now, and it's already plenty
good. But I was thinking, is there really no way to incrementally build a type
via sequential calls to to `addAction`?

Let's put down first what is clear that we can't do: the type of an object
can't be refined after its initialization. Which means the class
implementation is a dead-end for that kind of shenanigans.

But.

But we could use an immutable, functional programming type of solution where
we keep building a new object with a new type each time we add an action!

For the sake of keep code as clear as possible, from here on I'll simplify the
definition of my dux object to just be  a bag of actions:

```
type Dux = Dictionary<Function>;
    

function addAction( dux: Dux, name: string, creator: Function ) {
    return {
        ...dux,
        [name]: creator
    }
}

const dux = addAction({}, 'doThis', () => {} );
```

That works, but the type of `dux` will be a generic object of functions. If we
want to be more specific, we have to do:

```
function addAction<
    D, K extends string 
>( dux: D, name: K, creator: Function ):
    D & { [key in K]: Function 
{
    return {
        ...dux,
        [name]: creator
    } as any
}

const dux = addAction({}, 'doThis', () => {} );
```

Woo! `dux` shows as having the key `doThis`. Success! 

Now we can do

```
let dux = addAction({},  'doThis', () => {} );
    dux = addAction(dux, 'doThat', () => {} );
```

and... what? `dux` type is still an object with `doThis` as the sole allowed
key? Oh. Oh yeah. That's because once TypeScript assigns a type to a variable,
that's it, it's stuck with it. 

That's unfortunate. It means that we could call `addAction` many times, but to
get the right type we'd have to assign a new variable each time:

```
const dux  = addAction({},   'doThis', () => {} );
const dux2 = addAction(dux,  'doThat', () => {} );
const dux3 = addAction(dux2, 'doSomethingElse', () => {} );
const dux4 = addAction(dux3, 'killMeNow', () => {} );
```

Or we could bypass the intermediate variables altogether:


```
const dux = 
addAction(
    addAction(
        addAction(
            addAction({}, 
                'doThis', () => {} ),  
                'doThat', () => {} ),
                'doSomethingElse', () => {} ), 
                'callbackHellIsBack', () => {} );
```

But that's just plain ludicrous.

There is actually a third option, which is a little bit cheating... We could 
use the way promises can be chained to cut on the silliness:

```
const dux = await Promise.resolve({})
    .then( dux => addAction(dux, 'doThis', () => {} ) )
    .then( dux => addAction(dux, 'doThat', () => {} ) );
```

In this case, our `dux` will have the right type! We can even shave a little
bit of the repetition thanks to currying:

```
function curriedAddAction<K extends string>(name: K, creator: Function) {
    return <D>(dux:D) => addAction(dux,name,creator);
}

const dux = await Promise.resolve({})
    .then( curriedAddAction('doThis', () => {} ) )
    .then( curriedAddAction('doThat', () => {} ) );
```

## In conclusion


As I said, right now I'm sticking with the first solution. The requirement of
assigning actions at object initialization is not a huge onus -- one could
even argue it helps the code to stay simple -- and hasn't been an impediment
so far. But it's interesting to know that there are ways -- painful ways,
insane ways, but ways -- to push the envelope a little further. 

Enjoy!
