---
created: 2017-05-12
---

# Type Schmecking

These days, my pilgrimage through the divided kingdoms of EcmaScript made me 
skirt the boundaries of [Typescript](typescript)landia. From my short
expeditions within, I have to admit: Typescript **is** a nice superset 
of JavaScript. And its main feature, type checking, is sure a fresh breath of
structure in an otherwise world of
*stick-them-in-the-object-and-let-the-consumers-sort-em-out* free-for-all.

But... 

after getting up to speed with all the newest bells and whistles of
EcmasScript, I'm feeling a bit relunctant to turn my back from my newly
coalesced understanding and dive into yet another dialect.

But... 

type checking is sure a nice thing to have. While this programming
pattern of sticking everything in unstructured objects makes for quick code
churning, it also makes for stream-of-consciousness APIs that are wretched
breeding grounds of typos and forever-diverging 
naming variations.

So I thought... hey, there is that [JSON Schema][json-schema] thang I keep
playing with. That's also validating data structures... Hmmm... What if-- I
mean, how
about-- Oh hell with it. You know what? 
Let's hop down that rabbit hole and see where its leads...

## Checking with Schemas (hence the *schmecking*)

Unlike Typescript, I'm interested here about runtime 
type checking. (mostly because taking on compile-time checking
would be aiming *way* above my grade).


##hackthrough

### ./example1-1.javascript

To do that, it'd be nice to take regular function...

### ./example1-2.javascript @1

...and label it with the checks we want to perform.
Both for the functions arguments...

### ./example1-3.javascript @2,3

...and its return value.

### ./example1-3.javascript 

Hmmm... Isn't there an EcmasScript upcoming feature dealing with labelling
things? 

...or was it marking? 

...adorning? 

### ./example1-4.javascript @1,2

Decorators!

##/hackthrough

Once I knew I wanted to use decorators, the rest was pretty much
creating a nice wrapper around the JSON Schema validator module [Ajv][ajv]
to make it happen. I won't bore you with the implementation details -- 
the proof of concept is on [GitHub][jstc] for your perusing/forking/stealing
pleasure. Suffice to say that it works. 

## A simple example

##hackthrough

### ./example2-1.javascript

Here is our example, with all the actual code. 
Note that we have to wrap the method in a class
to be able to use the decorators.


### ./example2-2.bash

... and the output. 

Not bad, eh?

##/hackthrough

## Using the data to check the data? Check.

Since we are using JSON Schemas, and doing things at runtime, there are a
few more goodies within hand's reach. One you might already have noticed: 
JSON schema validation can do simple checks on the values (min/max length or
value and that sort of things).  And thanks to `Ajv`'s bleeding edge support of
JSON Schema specs, it goes further: those
checks can refer to the data itself.

##hackthrough

### ./example3-1.javascript

Simple function where we want the second argument to be equal or 
greater than the first.

By the by, the `1/0` value for `$data` is a JSON pointer, basically meaning
"take the 0th (i.e., first) children of my parent as the value".

### ./example3-2.bash

Bingo.

##/hackthrough

## Forgot to provide a value? Can't see default in that

Thanks to another `Ajv` rad feature, we can have our 
validation populate default values as well.

##hackthrough

### ./example4-1.javascript

How about having a default tip of 2 bucks?

(yeah, yeah, I could have used `tip = 2` in the function
signature. It's an example, work with me here)


### ./example4-2.bash

Done.

##/hackthrough

## Going schemad with the power

So far we've used ad-hoc types, but we can also use full-fledged 
schemas. And since they are JSON schemas, they could be processed
into documentation elsewhere.

(Oh yeah, writing a Vue-based JSON schema viewer is in my todo list.
Did I mentioned that?)

```javascript
import JsonSchemaValidator from './json-schema-validator';

const { args, returns } = JsonSchemaValidator({
  schema: {
    definitions: { 
      bill: {
        type: 'object',
        properties: {
          amount: { type: 'number', documentation: 'raw amount' },
          tax:    { type: 'number', documentation: 'sigh...' },
          tip:    { 
            type: 'number',
            default: 2.00,
            documentation: "gratuity, because we're not savages"
          },
        }
      }
    }
  },
});

class Foo {

    @returns('#bill')
    static calculate_bill( amount, tip ) {
        let bill = { amount };
        bill.tax = amount * 0.10;
        if ( tip ) bill.tip = tip;
        return bill;
    }

};

```

## This ain't nowhere close to being over...

And that's just the tip of the iceberg. By default
check violations are only logged as errors, but there is
already a configurable callback that can be tweaked to
do anything else, from nothing to dying violently. While it's not implemented
right now, it would also be easy to add a flag that would turn all type checks
into no-ops if our production code has a need for speed.

So yeah, expect to see more updates on this specific project 
in the future. Meanwhile, enjoy!


[jstc]: https://github.com/yanick/json-schema-type-checking
[ajv]:  https://github.com/epoberezkin/ajv
[typescript]: https://www.typescriptlang.org/ 
[json-schema]: http://json-schema.org/documentation.html
