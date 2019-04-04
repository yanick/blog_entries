---
created: 2017-08-06
tags:
  - redux
  - javascript
  - stygma
---

# STYGMA: Redux

This article is 
introducing *STYGMA*, a new series of blog entries where I'll 
foolhardingly pretend to be an expert and present the
gist of a technical thingy  --  library, framework, tool, or whatever strikes my fancy --
with a tone, pace and rigour so fast and furious you'll find yourself reaching for the 
gear shift.  

Why call the series *STYGMA*? Well, stick around to the end of the article, and it'll all
become clear. Kind of.

(by the by, if you do happen to enjoy this blog entry, you might also
like the [talk I gave to the Toronto Perl Mongers][toronto] earlier this year, or even
the Perl clone of Redux [I came up with][pollux])

##  KISS me, you fool

What is Redux? It's a
JavaScript framework meant to manage the state of applications (or just any other type of program, really, it's not picky).

As far as frameworks go, it's a helluva of a light one. Almost more of a methodology, really. Most of the mechanics of Redux 
have a very strong taste of functional programming, which is cool. They also 
aim at making things as simple and fool-proof as
possible, which is even better. Most of it is 
achieved using just plain JavaScript (well, modern-flavored Ecmascript6. Spartan is good, ascetic is pushing it too far),
and the bits that comes with the library Redux are mostly fairly basic helper functions. Bottom line, if you already have a
good base of JavaScript, Redux will feel like trying a new beer at your local pub instead of, say, being thrown in the vat of an
unknown brewery.

## Keeping our sh--, I mean, stuff  together

The first thing Redux does is to realize that the state of an application
often looks like a teenager's room. There a global variable here, a heap of
objects there, and in that corner... is that an open socket slowly leaking?
That's organizational disgrace. Instead, with Redux the *whole* state of the app is crammed in a store, 
which is a plain data structure. If we'd be working on a
spaceship game, it could look like the following

```javascript
{
    game: {
        turn: 3,
        players: [ 'yenzie', 'bob' ],
    },
    objects: [
        {
            name:     'Enkidu',
            coords:   [ 0, 0 ],
            heading:  90,
            velocity: 3
        },
        {
            name:     'siduri',
            coords:   [ 10, 0 ],
            heading:  0,
            velocity: 0
        },
        
    ]
}
```

In addition of being a plain structure -- typically an object, but it can also be an array, or even a single scalar 
-- it has to be serializable. That means no
functions, no funky business, no nothing but stuff that can survive serialization/deserialization.

Straightforward, pragmatic, put together yet not overly clever -- think of it of a Han Solo where carbonite is
switched for JSON.

## Look, but don't touch

Second crucial concept of Redux: we won't touch the state object of the store directly.

Instead, we adopt an interaction style strongly endorsed by anyone ever having
dealt with Hannibal Lecter.  Keep your source of truth in total isolation. You
can look at it and interrogate it, but physical interactions are strictly
forbidden.  Communication coming from the outside world is done via messages
passed through a little transparent box. 

Those messages, in Redux-land, are called *actions*, and they specify the
modifications we want to bring to the store's state. They are (again) plain JavaScript 
objects, and their only required feature is to have a `type` attribute.
The type is typically an uppercased string. Mostly because things work better 
when you shout.

## hackthrough

### ./actions_1.javascript

Simple action.

### ./actions_2.javascript

Action with a payload. The payload can be anything you wish, in whatever format you fancy.

### ./action_3.javascript

Some people prefers to encapsule the payload
in its own attribute.


##/hackthrough

## Transimmutability

We have our state. And we have an action. So how we change the 
former with the latter?

We don't.

Yes, I know, I said-- and you thought-- and it's kinda obvious that we should-- 

You know what, 
don't reach for the aspirins yet. Let me explain.

### Quick interlude: functional programming's metathesiophobia

This is pretty much where functional programming barges in. One of the big 
credos of that programming style is that a constant source of programmatic pain is the 
mutability of variables. Indeed, consider the following snippet.

```
const message = "Hello world";

console.log( message );
```

Isn't beautiful? As easy to understand as it is unambiguous, its simplicity 
is downright poetic.

Now, constrast it with this next snippet.

```
let message = [ 'Hello', 'world' ];

do_things( message );

console.log( message.join( ' ' ) );
```

Do you feel it? The crushing grasp of existential angst closing around your 
soul?  What are the things that `do_things()` does? Is it modifying the
message? How can we be sure what the console will print? Why is the world
spinning that fast? The walls, they're closing on us! Noooooo....

Okay, I might have simplified things a trifle here and added a dab of drama there. But the point
to take home is that there is some wisdom in trying to keep the mutability of
things under control. There are good arguments for it, and one day I might write a
blog entry about the joys of immutability, but for now, let's return to Redux.

## Transimmutability, part II: inducing the seducing reducers

As I was saying before the segue, we won't alter the state. Instead, 
we'll build a new state based on both the old state and the action via the transmutative
powers of a function called a *reducer*.

Sounds scary, but it's not.
A reducer is just 
a function that takes in the previous state and an action, and spits out the 
resulting new state.

```javascript
let new_state = reducer( old_state, action );
```

I say a simple function, but it needs to obey two important directives. Just like you should never get your Gremlin wet, or feed it
after midnight, there are two things you must not do with your reducer.

* The reducer must have no side effects. That is, it must not change any global variable, not print anything to the
console, not write to disk, not send anything over the network. It spits out the new state, and does **NOTHING** else.

* The outcome of the reducer must be deterministic. This is to say, for a given pair of
`old_state` and `action`, it should always, *always* return the same `new_state`. So no stochastic *leger de main* with
random numbers, or different behavior depending of the time of day. We want consistency, *capiche*?

Incidentally, if you're interested to speak the lingo of functional programming, this is called a *pure function*. 

## Let's get our hands dirty

That all sounds nice, but it's time for a concrete example. Let's make a shopping cart!
Not terribly exciting nor original, but it'll serve its purpose right.

Our cart's state will be simple: a list of items, and a summary section.

```
// initial state
let state = {
    summary: {
        total:     0,
        nbr_items: 0,
    }
    items: [],
};
```

To change our state, we need actions.
At this point, adding items 
to the poor empty cart would probably be the obvious thing to do.

```
let action = {
    type: 'ADD_TO_CART',
    payload: {
        item: 'TSHIRT',
        price: 20.21,
    },
};
```

So far, so good. The action describe what we wanna do. Now let's write the 
reducer to turn that wanna into a tadah.

## hackthrough

### ./reducer_1.javascript

We know the rules: two parameters enter the reducing arena, one state will
come out.

### ./reducer_2.javascript @2-11

The action is a `ADD_TO_CART`? Update the state
in consequence.

### ./reducer_3.javascript @12

Not any action we know? Fine. Return the state unchanged.

##/hackthrough

### Quick interlude: back to functional programming's metathesiophobia

I know what you are thinking. "Why are we doing such 
convoluted assignments? Why not just do the following?"

```
function reducer( state, action ) {
    switch( action.type ) {
        case 'ADD_TO_CART':
            state.summary.total += action.payload.price;
            state.summary.nbr_items++;
            state.items.push( action.payload );
            return state;

        default: return state;
    }
}
```

That's because we don't want to alter the old `state`, and that's exactly what 
that simpler code will do as collateral damage. 

Why we don't want to change the old state?
Well..  I'll explain that in a few sections, but trust me, we really don't.

The funny thing is, though: for all the *engouement* for functional programming
going on in the JavaScript world, the language itself is not very strong on 
immutability. Ditto, by extension, for Redux. We are *supposed* to keep our values
immutable, but by default the only tools we have for that is pretty much our
our own sense of virtue. Not a comforting thought. 
If you want to
hedge your chances, there are a few libraries that can help (e.g. [Immutable.js][immutable.js] 
and [seamless Immutable][seamless]) 
as well as Redux plugins that help integrate them with the framework.

## Evolving the cart

Let's add two more actions to make things a tad more
sophisticated.

```
let set_clear_cart = {
    type: 'CLEAR_CART',
};

let set_tax_action = {
    type: 'TAX',
    payload: {
        percent: 0.10,
    },
};
```

Let's also upgrade the reducer to deal with them.

##hackthrough 

### ./upgrade_1.javascript

Previous version.

### ./upgrade_2.javascript @3-7

Adding `CLEAR_CART` code.

### ./upgrade_3.javascript @9-13

And then the `TAX` code.

##/hackthrough 

## Vroooooom, Go cart!

And we have ourselves a nice little Redux store.  
With only three actions it might still be pretty trivial, but 
it's enough to be functional.

!(mermaid:files/cart.mmd)



By the by, see what I did there? Three actions...? *Tri*vial..?

...

moving on.

## Divide and conquer

Not bad. But we can see, as the state gets big and the list of actions
grows, that reducer is going to become quite the beastie.

Nicely enough, the reducer has some amenable properties that allows to cut it into smaller
parts. Like, notice how the `summary` and the `items` parts of the state both react to
actions, but don't interact with each other? What means that we can split the functionality
and deal with the state subsections individually.


##hackthrough 

### ./simplify_1.javascript 

So we take our monster reducer.

### ./simplify_2.javascript 

... and we slim it down through the "we'll deal about it elsewhere" diet.

### ./simplify_3.javascript 

The sub-reducers are still using the same logic, just
more localised.

### ./simplify_4.javascript 

Which means smaller, more focused functions, and 
long `state.items`-type names shortened to `state`.

Me gusta.


##/hackthrough 


Already a little easier to chew on, isn't?  Basically, each sub-reducer only deals with its part of the state, and the state
can be recursively divided in as many subsections as wanted.

!(mermaid:files/cart_divided.mmd)


And we don't need to do it upfront either; it's pretty easy
to refactor and add sub-reducers as the state evolves and grows. For example, that `summary_reducer` above still
feels too big? Null problemo.

## hackthrough

### ./subreducer_1.javascript

Start with the original summary reducer.

### ./subreducer_2.javascript

Each of the three attributes get its own
sub-reducer. 

(feels a lot like what we did to the original reducer, isn't?)

### ./subreducer_3.javascript @1-11

The reducer for the total.

### ./subreducer_4.javascript @1-3

... and the one for the tax...

### ./subreducer_5.javascript @1-9

... and finally the one for the number of items.


##/hackthrough


Because the sub-reducers are independent of each other (and don't rely
anything beside the state and action they are given as parameters), it also
means that each of them is easy to test on its own. That's nice. 

### Easier still

With the use of Redux helper functions and some ES6 tricks, we can shorten
that code even more.  I won't go into details, but here how a full-squished
version of our code could look like.

## hackthrough

### ./with_redux_1.javascript 

We reach for Redux's helper functions.

### ./with_redux_2.javascript @3-6

Main reducer is made of two sub-reducers. 

In case you don't remember,

```javascript
{  foo, bar }
```

is equivalent to

```javascript
{  foo: foo, bar: bar }
```

### ./with_redux_3.javascript @3-9

Adding the items reducer called, o surprise, `items`.


### ./with_redux_4.javascript @3

Summary reducer, made of more reducers!

### ./with_redux_5.javascript @3-9

Total reducer. Like, totally dude.

### ./with_redux_6.javascript @3-5

Taxes.

### ./with_redux_7.javascript @3-9

And finally the nbr_items reducer.


##/hackthrough

## A game with savepoints

Time to draw the spotlight on one of Redux's killer features: its mastery 
over, appropriately enough, Time.

Remember how the state of the application (or program) is entirely 
contained by the Redux store, and is 
crafted such that it's serializable? That means that at any given time you can
potentially save the store, and later on load it in another instance of 
the application and you are going to be exactly in the same state. Guaranteed.

If you ain't on your knees crying tears of joy right now, 
I can only imagine it's because you never did any testing 
or went on a bug hunt before.

But wait, it gets better!

Any bug hunter will tell you: the state of the application
is only half of the story. You also need to know how you got to
that point. No problem. We can easily save the store every time there
is a change, and we can use those different still frames to reproduce
the film of events. (incidentally, the big deal we made of respecting the 
immutability of the previous states earlier on? that's one of the big reasons why)

Wait, wait, wait! we can do betterer still!

Remember how we harped long and hard about the reducer having to
be without side effects, and being deterministic? Well, that means
that if I give you an initial state, and a list of actions that have been generated,
then you can always figure out the final state via

```javascript
state = actions.reduce( 
    ( state, action ) => reducer( state, action ), 
    state 
)
```

That means that you can
have a view of the store before and after every action (or group of actions).
If you craft your actions to be meaningful, that can make the logic pretty nice
to follow. Not to mention that it makes testing of particular scenarios a breeze.

And did I mentioned that you can have all that goodness for free
and wrapped in a purty package as that recording/playback/diff'ing
functionality is readily available as browser plugins ([Firefox][firefox] and [chrome][chrome]).

## Expecting the unexpected

I'm sure that at this point you're all amazed and sold. But
if I give you some time to think about it, you'll realize the pretty humongous
pachyderm I left in the room.
All those side-effects 
I poo-poo'ed? Those random behaviors I sneered at? Those 
network interactions I banned? I might wish we could do
without them, but unless your app is boring to the extreme,
chances are you can't, and want to have them integrated
to your state management.

Fortunately, there's a loophole.

See, what we insist on is for the reducer be a pure function, 
but we never said anything about what happens *before* we hit it.

What we'll do is to add a new stage between the application code
itself and the reducer. In this stage we'll stuff functions that we'll
call *middleware*. These middleware will intercept actions as they pass by, 
be given perusal access to the store, as well as the ability to dispatch 
new actions. 

!(mermaid:middleware.mmd)

That's all there is to the general concept of middlewares. As to their use
and implementation, that's another story. Which I might tell in a subsequent STYGMA
blog entry. But for now I'll just briefly give an example so that you have an idea what
it looks like.

This example will be the super-happy cheerful not grim at all 
implementation of the store of a Russian Roulette game. 

The state of the game will have a `loaded_chamber` relative to the current chamber, as well
as a `alive` flag. To communicate with the store, we'll have two actions: `LOAD_GUN` and `PULL_TRIGGER`.

##hackthrough

### ./russian_1.javascript 

We begin with the reducer's boilerplate. We define 
a original state as the default `state`, but
otherwise have all actions pass through.


### ./russian_2.javascript @10-13

Adding state change for `LOAD_GUN`.

### ./russian_3.javascript @10-26

And  for `PULL_TRIGGER`.

##/hackthrough


Now let's add two middlewares. One that starts the game with some randomness,
and another that pushes something to the network when the player, ahem, suffer
defeat.

##hackthrough 

### ./middleware_1.javascript 

We import the helper tools from Redux.

### ./middleware_2.javascript 

Middlewares are curried functions. They get
three arguments: the store, the function
that will push the action to the next middleware or
into the reducer's maws, and the action itself.

### ./middleware_3.javascript @2-2

If we want the middleware to be a passthrough,
we just call `next(action)`.

### ./middleware_4.javascript @6-9

If we see a `START_GAME` action, we don't propagate 
it (we could, if another middleware 
or the reducer were to do something with it), but rather
dispatch a new `LOAD_GUN` action.

### ./middleware_5.javascript

For the `end_of_game` middleware, we
first propagate the action.

### ./middleware_6.javascript @5-9

... and then check if it the said action
had any... messy outcome.

### ./middleware_7.javascript

Finally, we configure the store to
use the middlewares. 


##/hackthrough

And that's it. We can now play a game!

!(mermaid:files/game.mmd)


## Listenin' in

There is one last itsy core component to Redux: it's possible to subscribe listener functions to
the store. Those functions are called each time the store's state change. For example,
the `end_of_game` middleware of the last section could be replaced by a subscriber that
goes "are they dead yet?" each time something happen.


##hackthrough

###  ./listener_1.javascript 

Creating the store as before, minus the `end_of_game` middleware.

###  ./listener_2.javascript

Add a listener that keeps track of the last
known cranial integrity of the player, and does
the announcement if things changed for the worse.


##/hackthrough

!(mermaid:files/listener.mmd)

In fact, since the listener can also dispatch actions to the store... why not
save a few clicks to the user, and automatically play the game to its logical, nihilistic
conclusion?

```javascript
let was_alive_at_last_news = true;

store.subscribe( () => {
  if ( !was_alive_at_last_news ) return;

  if ( store.getState().alive ) {
    // still alive? AW RIGHT!
    store.dispatch( { type: 'PULL_TRIGGER' } );
    return;
  }

  audio_system.broadcast(
    "Cleaning requested at aisle 5..." 
  );

  was_alive_at_last_news = false;
})
```

!(mermaid:files/listener_2.mmd)

## S.T.Y.G.M.A.

Of course, there are plenty more details, and undoubtly a gazillion things I'm
forgetting. Still, for an introduction, it'll have to do.

So There You Go, Mes Ami(e)s: *Redux*.

  [toronto]: https://www.youtube.com/watch?v=Ehl9VAYzfcg
  [pollux]: https://www.iinteractive.com/notebook/2016/09/09/pollux.html
  [seamless]: https://github.com/rtfeldman/seamless-immutable
  [immutable.js]: https://facebook.github.io/immutable-js/
  [firefox]: https://addons.mozilla.org/en-US/firefox/addon/remotedev/
  [chrome]: https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en

