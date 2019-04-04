---
created: 2017-01-04
---

# Typing JavaScript with JSON Schema

I had an idea. It's half-formed, probably not a good one, but hey, I thought
it'd be fun to share.

## Context

In the last couple of months, while I'm patiently for the latest
[Battletech][] game to become available, I'd been working on my port of
[FullThrust][]. Because I want it to be a educational experience,  I've decided
to go full JavaScript for both the frontend and backend. And I really mean,
full-frontal, no hold barred, *modern*, *bleeding-edge* JavaScript.

The result so far? On the game front, the progress has been *abysmal*. But oh
boy did I learn a lot. 

I will spare you the long list of frameworks that the project iterated
through. Suffice to say that the state engine at the core of the application
is converging toward a global store -- the penultimate incarnation was using
[Redux][], and the current one is using [VueX][].

Since all those stores use JavaScript objects to both represent the main store
as well as the actions that alter it, one of the very latest yak to step on
the barber chair was typing systems. Because, I'm at least sufficiently
self-aware to know I'm a scatterbrain who will never remember from one file to
the next if I settled for 

```
let movement = {
    heading:  1,
    velocity: 1,
    coords:   [ 0, 5 ],
};
```

or

```
let movement = {
    bearing: 1,
    speed:   1,
    coords:  [ 0, 5 ],
};
```

At the very least I have to find a comfortable way to document my data
structures. And if I can make my program automatically check that what I'm
passing around remotely look like what it's supposed to, hey, that'd be
wondertastic.

## Good enough won't be left alone

As it happens, there are two big contenders (that I know of) in the JS
ecosystem for typed systems. [TypeScript][] and [FlowJS][]. TypeScript is a
whole superset of JavaScript, while Flow is strictly about type checking. Both
are nifty by their own right, but they are not eeeexactly scratching my itch.
After all that time spent embracing the latest, purest, uncut EcmaScript, I'm
not sure I'm ready to veer toward TypeScript. And as for Flow, I tried to see
how well it'd work with [Vue][] and [Webpack][] and, urgh, I think I reached
the number of transpilations I can live with.

So what does that leave me with?

## A mad scheme arises

Well, that leaves me with something that's already in
my toolkit: [JSON Schema]. Sure, it's a little bit verbose, but that's
another perfectly cromulent way to express types. And it has some advantages
over the TypeScript and Flow alternatives.

For one, it's language agnostic, so can probably be used more-or-less straight
for the [OpenAPI][] or [RAML][] web service the game will have.  Or even
be used to create equivalent types in, say, Perl using
[JSON::Schema::AsType][]. 

It also allow for more sophisticated types. Sure, with TypeScript or Flow you
can say that the property `foo` is a number. But using the latest JSON Schema,
you can not only set ranges, but you can also make it dependent on other
properties of the object.

```js
var schema = {
  "properties": {
    "thrust": {
      "type":    "number",
      "minimum:  0,
      "maximum": { "$data": "1/engine_rating" }
    },
    "engine_rating": { "type": "number" }
  }
};
```

YAGNI-assured overkill? Perhaps. But so much power... it *is* alluring.

## What it looks like 

So, how would type-checking variables and stuff would look like with that kind
of scheme? I'm still playing with it and haven't generated anything generic
yet, but here is what my current implementation in that game of mine looks
like.

First, there is the `Game/Schema/index.js` module that encapsulates both the 
schema itself, and the validation functionality.

For the JSON schema itself, I'm leveraging [ajv][] and, to sweeten the
process, my own [json-schema-shorthand][]:

```  js
import Ajv       from 'ajv';
import shorthand from 'json-schema-shorthand';

let schema = {
    id: "http://aotds.babyl.ca/schema.json",
    definitions: {
        movement: { 
            id: "#movement",
            object: {
                velocity:        "number!",
                heading:         "number!",
                coords:          'object!',
                trajectory:      'object',
                remaining_power: "number",
            }
        },
        "ship_navigation": {
            id: '#ship_navigation',
            "object": {
                heading:  'number!',
                velocity: 'number!',
            },
        },
    },
};

let ajv = new Ajv();

ajv.addSchema( shorthand( schema ) );
```


For the validation, I basically want a way to wrap values and functions
such that I'll get squeaks of outrage if they don't produce what's expected of
them.


``` js
// everything's better with a lodash of salt
import _ from 'lodash';

// logging stuff
import StackTrace from 'stacktrace-js';
import Bunyan     from 'bunyan';

let logger = Bunyan({ name: "aotds", src: true, level: 'debug' });

function _validate_type( type, data ) {
    let v = _.partial( 
        ajv.validate, 
        ( typeof type === 'object' )
            ? type 
            : { '$ref': 'http://aotds.babyl.ca/schema.json#' + type }
    );

    let res = v(data);

    if(!v(data)) {
        StackTrace.get().then( trace => {
            // first 2 stack items are for
            // _validate_type and validate_type, so
            // not really interesting
            trace.splice(0,2);

            // filter out library stuff to cut on the noise
            trace = trace.filter( t => ! /node_modules/.test(t.fileName) );

            logger.warn( { 
                trace,
                data,
                schema_error: ajv.errors,
                definition:   type,
            }, 'schema validation' )
        }
    )};

    return data;
}

export default
function validate_type(type) {

    return input => {
        if( typeof input === 'function' ) {
            return (...args) => 
                _validate_type( type, input.apply(null,args) );
        }

        return _validate_type( type, input );
    };
}
```

And, well, that's it. And its use is not too obtrusive either. For example,
where I had

```js
export
function ship_calculate_movement( ship, orders = {} ) {
    // lotsa stuff goes here
}
```

I can now do

```js
import _t from 'Game/Schema';

export
let ship_calculate_movement = _t('movement')( ( ship, orders = {} ) => {

    _t('ship_navigation')( ship );

    // lotsa stuff goes here
});
```

and I'll get big fat warnings if `ship_calculate_movement`
returns something that is not fitting the movement type, or
if it's being fed an unnavigable ship. And while it's not as
pretty as 

```js
function ship_calculate_movement ( ship: ShipNavigation, orders = {} ) : Movement { 
	... 
}
```

it's 100% pure JavaScript and doesn't require any transhenaniganifactions. I can live with that.

Of course, I'm already see a lot of room for tweaks
and improvements. For example, it'd be easy
to have a configuration knob to throw errors when encountering
malformed data. And to make the logging mechanism pluggable. Or allow
the type checking to become a straight bypass for production and/or
need for speed.

But that's something for tomorrow. For the time being,
I have a game to write. In the short, oh so terribly short 
time I have before the
next yak jumps me.

 [Battletech]:            http://battletechgame.com/
 [FullThrust]:            https://en.wikipedia.org/wiki/Full_Thrust
 [Redux]:                 http://redux.js.org/
 [VueX]:                  http://vuex.vuejs.org/
 [TypeScript]:            https://www.typescriptlang.org
 [FlowJS]:                https://flowtype.org
 [Vue]:                   http://vuejs.org/
 [Webpack]:               https://webpack.github.io/
 [OpenAPI]:               https://www.openapis.org/
 [RAML]:                  http://raml.org
 [JSON:                   :Schema::AsType]:  https://metacpan.org/pod/JSON::Schema::AsType
 [ajv]:                   https://github.com/epoberezkin/ajv
 [json-schema-shorthand]: https://www.npmjs.com/package/json-schema-shorthand
 [JSON Schema]: http://json-schema.org



