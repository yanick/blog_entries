---
created: 2017-01-04
---

# Say 'Hello' to JSON::Schema::AsType

In mathematics, a common approach to solve new problems is -- instead of trying to
solve them head on -- to find a way to define them as a transformation of an
already known, already solved problem. That way, you don't have to spend hours
reinventing the wheel where you can spend days and weeks floating in the
meta-sphere, getting your mind blown away by layers upon layers of
abstractions until the sheer recursiveness of it all drive you to the
nihilistic solace of alcohol and cave-dwelling seclusion.

*Ahem.*

What I'm trying to say there, is that there I was, working on a secret project
(hint: it has to do with [Dancer](cpan:Dancer), with
[Swagger](http://swagger.io), and will be awesome). Project is doing
amazing, and I reached the point where it'd be groovy if I could
validate [JSON schemas](http://json-schema.org) in Perl. There is
[](cpan:JSON-Schema), but it's not quite passing all the draft4 test cases.
And there is [](cpan:JSV), which I was going to use when I thought...

A JSON Schema, when you get down to it, is nothing but the definition of a
structure, isn't? Or, as we programmers would say, a type.

Wouldn't it be nice, then, to be able to take a JSON Schema and turn it into
a [](cpan:Type-Tiny) type?

So say hello to [](cpan:JSON-Schema-AsType). It slices, it dices, and it
passes all draft3 and draft4 test suites.

```perl
use JSON::Schema::AsType;

my $schema = JSON::Schema::AsType->new(
    specification => 'draft4',
    schema => {
        properties => {
            foo => {
                enum => [qw/ alpha beta gamma /],
            },
        },
    },
);

my $type = $schema->type; # there ya go, a nice Type::Tiny type!

print "valid!" if $type->check( { foo => 'delta' } ); # won't print
```

And because we're piggy-backing on Type::Tiny's goodness, schemas
that don't validate have explanations that are... well, okay, maybe
not the most beautiful in the world, but at least decently informative.

For example,

```perl
say for @{ $schema->validate_explain({ foo => 'delta' }) };
```

would give you

```
"~JsonObject|Dict[foo=>Optional[Property],slurpy Any]" requires that the value pass "Dict[foo=>Optional[Property],slurpy Any]" or "~JsonObject"
Reference {"foo" => "delta"} did not pass type constraint "~JsonObject"
    Reference {"foo" => "delta"} did not pass type constraint "~JsonObject"
    "~JsonObject" is defined as: (not(((ref($_) eq 'HASH') and (not((Scalar::Util::blessed($_)))))))
Reference {"foo" => "delta"} did not pass type constraint "Dict[foo=>Optional[Property],slurpy Any]"
    Reference {"foo" => "delta"} did not pass type constraint "Dict[foo=>Optional[Property],slurpy Any]"
    "Dict[foo=>Optional[Property],slurpy Any]" constrains value at key "foo" of hash with "Optional[Property]"
    Value "delta" did not pass type constraint "Optional[Property]" (in $_->{"foo"})
    $_->{"foo"} exists
    "Optional[Property]" constrains $_->{"foo"} with "Property" if it exists
    "Property" is a subtype of "Enum"
    Value '"delta"' doesn't match any of the enum items:'"alpha"' '"beta"' '"gamma"' (in $_->{"foo"})
    "Enum" is defined as: sub { package JSON::Schema::AsType::Draft4; my $j = to_json($_, {'allow_nonref', 1, 'canonical', 1}); any sub { $_ eq $j; } , @enum; }
```

There is still room for improvement there, but then, we're still at version
`0.0.1`. In the next little while, I'd like to clean up the error messages,
such that it's informative for all JSON schema keywords. I'd also add the
sugar such that we can also declare a type as

```perl
use JSON::Schema::AsType qw/ JsonSchema /;

my $type = JsonSchema[{
    properties => { ... },
}];
```

And, finally, to be able to create, and refine, schemas by providing examples.

```perl
my $schema = JSON::Schema::AsType->new;
  # would begin its live as ''{}'

$schema->refine({ foo => 'bar' });
  # would turn into
  # '{ type => "object", properties => { foo => { type => "string" } }'

$schema->refine({ quux => 1 });
  # would turn into
  # '{ type => "object", properties => {
  #     foo => { type => "string" },
  #     quux => { type => "integer" } }'
```

Bold plans. But then, there is the Holiday season, and lots of Egg Nog coming
soon, so... who knows. It might actually happens. In the meantime... Enjoy!
