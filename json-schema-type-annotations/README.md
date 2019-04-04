---
created: 2018-11-10
tags:
    - json-schema
    - javascript 
    - types
---

# PokeJSON Schema Final Form: Type Annotations 

If you follow my blog, you know I have a thing for [JSON Schema][json-schema]. 
It's language-agnostic, and thus allows to use the same 
type logic across [different languages][perl-astype].  Plus, it's defined by dirt-simple
data structures. That's the `JSON` part of its name, which frankly could have been
`Plain Old Object` if not for the fact that `POO Schema` is... mayhaps less marketing-savvy than
`JSON Schema`. Anyway, the point is: since those schemas are piles of POO,
they can be created and modified
programmatically if one feels inclined to dabble in the dark reflective arts.

Of course, me being me, the nano-second I decided JSON Schemas might
be worth, I was tinkering with ways to make it more ergonomic. 

## Make it short, make it sweet

The very first thing I did was to let out a deep sigh at the verbosity of it
all, and came up with
[shortcuts](https://iinteractive.com/notebook/2018/02/19/json-schema-shorthand.html),
which are bundled in the npm module [json-schema-shorthand][]. Because, frankly, why would anyone want
to write

```javascript
const schema = {
   description: "a thing",
   type: "object",
   properties: { foo: { type: "number" } },
   minProperties: 3
}
```

when one could write this instead:

```
const schema = object( { foo: 'number' }, "a thing", { minProperties: 3 } );
```

So, provided the right amount of helper grease, 
writing the schemas themselves is not too onerous. But that's only one 
part of the task. What about their use
to validate the input / output of functions? 

## Naivalidation

The straight-forward way of doing validation is to, y'know, doing it. Assuming
that we have a `validateSchema` function that does the deed, that could look like:

```

import { number, string } from 'json-schema-shorthand';
import validateSchema from 'god-knows-where';

const PositiveNumber = number({ minimum: 0 });
const NonEmptyString = string({ minLength: 1 });
const ReasonableString = string({ maxLength: 100 });

const myFunction = validateSchema( ReasonableString, function( s, n ){
    validateSchema(NonEmptyString, s)
    validateSchema(PositiveNumber, n);

    return s.length > n ? s.substr(0,n) : s;
})

```

That works. It's also a revolting jumbled mess of boilerplate that is as mind-numbing to
read as it is to write. In the original blog entry [where I explored the
possibility](/entry/typing-js-with-json-schema), 
I made it marginally less horrid. But not really by much. 

So, yeah, do we have other options? Like, the kind we'd actually *enjoy* using?

## the cosmetic value of decorators

The most obvious and promising one is class decorators. Using this feature, we
can have our original function, unbersmirched by unsightly boilerplate, and add
those decorators neatly at the top of the declaration where it's easy to see. 
I explored that path in [another blog
entry](/entry/type-schmecking). 

Using this
method, we could write the validation done in the previous section as 

``` 
import { number, string } from 'json-schema-shorthand';

const PositiveNumber = number({ minimum: 0 });
const NonEmptyString = string({ minLength: 1 });
const ReasonableString = string({ maxLength: 100 });

class MyClass {

    @args( NonEmptyString, PositiveNumber )
    @returns( ReasonableString )
    static myFunction( s, n ) {
        return s.length > n ? s.substr(0,n) : s;
    }

}
```

Already much better, isn't? The gotcha, however, is that decorators 
are only available for class methods and static functions. Of course, we
can always fudge things behind the curtain -- nobody needs to know that the function you 
export is in reality a class function. But... turning everything as a class
under the hood is still a little boilerplatish. Not as oppressive as our first
solution but, yeah, it feels like the moves are right, but the spirit is
subtly wrong.

Can we do better?

## Delicious curry and wraps

Better? I don't know. Differently? Sure!

JavaScript loves its function wrappings and currying, so why not play along?
We could, say, use wrapping functions doing the check-dances around
the original function.  For example, a wrapper validating 
the return value could look like:

``` 
const with_return = function (return_type) { 

    return function(originalFunc) {

        let return_value = originalFunc(...arguments);

        if (!validator.validate( return_type, return_value) ) {

            let errors = validator.errors; // promise ahead!
            StackTrace.get().then( stack => {
                    options.on_validator_error( 'return',
                    { value: return_value, errors,
                        stack: options.groom_stack(stack)  
                    });
            })

        }

        return return_value;

    };
};
```

And with it (and a `with_args` that does roughly the same thing, but at
the other end of the beast), we would have

```
const myFunction = 
    with_args( [ NonEmptyString, PositiveNumber ] )(
    with_return( ReasonableString )( 
        function( s, n ) {
            return s.length > n ? s.substr(0,n) : s;
        }
    ))
```

Not as ploddy as the original approach, but the parentheses juggling
makes it not quite as nimble 
nor elegant as the class decorators.

## If that won't do, how about `this`?

What about using the [proposed bind
operator](https://github.com/tc39/proposal-bind-operator)? The validation
functions remains mostly the same:

``` 
const with_return = function (return_type) { 
    let originalFunc = this;

    return function() {

        let return_value = originalFunc(...arguments);

        if (!validator.validate( return_type, return_value) ) {

            let errors = validator.errors; // promise ahead!
            StackTrace.get().then( stack => {
                    options.on_validator_error( 'return',
                    { value: return_value, errors,
                        stack: options.groom_stack(stack)  
                    });
            })

        }

        return return_value;

    };
};
```

And its invocation becomes:

```
const myFunction = function( s, n ) {
    return s.length > n ? s.substr(0,n) : s;
}
    ::with_args( NonEmptyString, PositiveNumber )
    ::with_return( ReasonableString );
```

It's cleaner, but the declaration of types is at the bottom of the 
function declaration, which is not the most optimal thing ever. I mean,
really, what
kind of monster does that?

## Pipe dream

If having the types at the end doesn't bother us too much, we could
use the [proposed pipeline
operator](https://github.com/tc39/proposal-pipeline-operator).

Here, the wrapping functions remain the same as originally, and 
their use become:

```
const myFunction = function( s, n ) {
    return s.length > n ? s.substr(0,n) : s;
}
    |> with_args( NonEmptyString, PositiveNumber )
    |> with_return( ReasonableString );
```

That's... not very different than the preceding variation, I'll give you.
But people seems to hate `this` and the bind operator, so it's nice to have a
second horse in that race. I guess.

## ok, enough mister nice guy

So far all those options are contained within the 
confines of valid JavaScript. Sure, I've twisted and bent meanings to 
express my dark desires, but I never broke syntactic rules. But conforming
to the rules is not what the cool kids do.
Look 
at type systems like [TypeScript][] and [Flow][]. They sneer at conformity and 
define their own extra syntax that is a superset of JavaScript. Forget about
awkwardly dancing
around the original function. They just plow ahead and boldly shove their
types in:

```
myFunction ( s : NonEmptyString , n : PositiveNumber ) : ReasonableString {
    return s.length > n ? s.substr(0,n) : s;
}
```

How do they get away with it?
By having a pre-processor that cleans away those types and dumbs down the code
to proper JavaScript. Which is not something us mere mortals can do.

...

Or can we?

## You don't like the rules? Rewrite them.

Isn't there [Babel][], which sole goal in life is to munge flavors of 
JavaScript back into *java franca*? 

And doesn't Babel already have plugins
to munge away the type annotations for both [TypeScript][munge-ts] and
[Flow][munge-flow]? In fact, isn't there even a [plugin that emulates
Flow validation, but at runtime][flow-runtime]?

So, very obviously, it possible to add in type annotations and have Babel
turn them into whatever we want. But as it is most of the time with software
development, the real question is not "*can it be done?*", but rather "*how
hard is it?*". 

## Building Babel baubles

I'll be honest: Babel is no piece of cake. After all, we're talking of
code munging code here -- the forbodding, dank corner of programming where hardened
hackers go to cry.

At a very high level, Babel reads the input code,
parses it into an Abstract Syntax Tree (also known as *AST* which, fittingly
enough, sounds just like one of the favorite swear words of my people), and 
converts that data structure back into JavaScript. That's, right there, three levels of
munging to grok. Fun.

Not only that, whereas some Babel plugins "only" deal with already-valid
JavaScript, here we are dealing with syntax-violating additions, so for want
we want, we can't
weasel our way out of hard work.

Kidding. We *totally* can cheat our way out of it.

Here cheating comes under the guise of appropriative piggybacking. As it happens, 
there is already a Babel plugin that [strips Flow annotations][flow-strip]
from the code. But here's the kicker: while it removes the type stuff from the
code (which is something we want to do as well), it **also populates the AST
with all the yummy type information we crave**.

In other words, if we keep our JSON Schema type annotations sufficiently close
to ones used by Flow, then using that Flow plugin takes care of the hard
tasks of parsing the source and populating the AST.  All that is left is the much
less daunting task of further manipulating the AST such that the type
validation is injected back.

### Prototyping those types like a typical pro

That's all sweet promises and honeyed hand-waving. 
Let's see how that theory survives implementation. 

For that, let's pick an example of what we'd like our annotations to look like:

``` 
import { number } from 'json-schema-shorthand';

const Stuff = number({minimum: 1});

function square( n : Stuff ) {
  return n * n;
}

console.log( square(2) );  // all good
console.log( square(-2) ); // goes *boom*
```

To gets us start, we 
add the following to `.babelrc`:

```
{
  "plugins": [ 
    "@babel/plugin-transform-flow-strip-types",
  ]
}
```

With that Babel turns our code into 

```
import { number } from 'json-schema-shorthand';

const Stuff = number({minimum: 1});

function square( n ) {
  return n * n;
}

console.log( square(2) );  // all good
console.log( square(-2) ); // goes *boom*
```

No validation is performed, but the code compiles. 
We haven't written a single
line of code and we're already halfway there. This bodes well.


## Where the rubber hits the code

Okay. No more trick left in the cheat bag for the validation itself. We need
to crack our knuckles and get to work. 

Just before we begin to write code, let's reiterate in plain English what we want
to achieve: we want to check out the AST of our code, and 
when we stumble across a function declaration with annotated
arguments, we want to inject the corresponding validation.

Reasonable? Clear? Good. Now let's turn that into code.

```
const babylon = require('babylon');

module.exports = function ({ types: t }) {
    return {
        visitor: {
            FunctionDeclaration(path) {
                let [ p ] = path.node.params;

                // no annotation? nuthin' to do
                if(!p.typeAnnotation) return;

                let name = p.name;
                let schema_id = p.typeAnnotation.typeAnnotation.id.name;
                
                path.node.body.body.unshift( babylon.parse(`{
                    const Ajv = require('ajv');
                    const ajv = new Ajv();

                    let valid = ajv.validate(${schema_id},${name});

                    if(!valid) {
                        throw new Error(JSON.stringify(ajv.errors));
                    }
                }`));

            },
        }
    };
};
```

In the immortal words of Samuel L. Jackson: "Tadah, motherfunctors".

Admittedly, this is a prototype that only considers the first argument of
the function, and doesn't cover all the cases that we can encounter in the 
AST. But still, isn't much smaller than you expected? A disclaimer, though:
the code might be short, but the time spent reading the AST API documentation
was long and involved.

In any case, if we add this code as another
plugin in `.babelrc`, it'll be sufficient to turn our original code into 

```
import { number } from 'json-schema-shorthand';

const Stuff = number({minimum: 1});

function square( n ) {
    {
        const Ajv = require('ajv');
        const ajv = new Ajv();

        let valid = ajv.validate(Stuff,n);

        if(!valid) {
            throw new Error(JSON.stringify(ajv.errors));
        }
    }

  return n * n;
}

console.log( square(2) );  // all good
console.log( square(-2) ); // goes *boom*
```

This will run. Will do what it's supposed to do. And yes, it will validate 
as well.  It's also pretty darn close to the original boilerplate we wanted to
run away from, but that's fine!  It's not like we have to look at that 
post-Babel output.

## TL;DR, please

To recap everything: 

JSON Schema is a cromulent option when one wants to 
do runtime validation of function inputs and outputs. 

While the required
boilerplate is fugly as a run-over duckling, it
is totally possible, to add those validations to vanilla JavaScript code. 

If one is ready to embraces the outer edges of Ecmascript via class
decorators, pipe operator, or bind operators, that ugliness can be mitigated
to something far less stomach-churning.

And if one has the hubris and the mental fortitude, the very syntactic rules of reality
can be grabbed and twisted to accommodate the type of notation TypeScript and
Flow use.

At the time of this writing, I haven't yet began to work on a *bona fide*
`babel-plugin-json-schema-validation`. And I might not do it, because it's
something that will require a wee bit of time and dedication. And yet...
Perhaps. if the stars align and I grow bored or develop a need for it. Then
perhaps, yes, I'll reach out and squeeze that plugin out.

If that happens, I'll let you know.


[perl-astype]: http://techblog.babyl.ca/entry/json-schema-astype
[json-schema]: https://json-schema.org/
[Babel]: https://babeljs.io/
[munge-ts]: https://babeljs.io/docs/en/babel-preset-typescript
[munge-flow]: https://babeljs.io/docs/en/babel-preset-flow
[flow-strip]: https://www.npmjs.com/package/@babel/plugin-transform-flow-strip-types
[flow-runtime]: https://codemix.github.io/flow-runtime
[json-schema-shorthand]: https://www.npmjs.com/package/json-schema-shorthand
[TypeScript]: https://www.typescriptlang.org/
[Flow]: https://flow.org/
