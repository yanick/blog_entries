---
title: Some Meta Fun With Moose and Avro
url: avro
format: markdown
created: 2012-08-11
tags:
    - Perl
    - Moose
    - Avro
---

I'll not try to bamboozle you: diving into [Moose](cpan)'s metaclass
system is not easy. Not because there is a dearth of documentation (*au
contraire*, it's gorgeously extensive), and not because the underlying code 
is hairy as a macaque in the middle of winter (considering the potent magics it
carries, it's surprisingly -- some would even say suspiciously -- sane), but
simply because playing with classes that beget classes is heady, confusing
stuff. It often feels like trying to type by looking at the keyboard in a
mirror. 

But once that dragon is tamed, it can do truly wonderful, terrible things...

For example, in my dream-quest for Unknown Hadoop, I stumbled on [Avro][avro], 
a data serialization system using JSON. I found its simple way to
describe data schemas... endearing, and began to wonder how hard it would be 
to auto-generate classes out of an Avro schema. Like, say: 

    #syntax: perl
    use Class::Avro;

    my $class = Class::Avro->new( schema => <<'END_SCHEMA' );
    { 
        "type": "record",
        "name": "PlayingCard",
        "fields": [
            { "name": "color", "type": "string" },
            { "name": "number", "type": "int" }
        ]
    }
    END_SCHEMA

For then be able to create new objects of the programmatically-minted
`PlayingCard` class:

    #syntax: perl
    my $card = $class->new_object( color => 'spade', number => 1 );
    
    say $card->color;

Or go one step further and deserialize directly from that `$class`:


    #syntax: perl
    my $other_card = $class->deserialize( q#{ "color": "heart", "number": "12" }# );

    say $other_card->number;

And, of course, it would also be nice to go the other way around: to have a
regular Moose class be able to spit out an Avro representation of its
attributes:

    #syntax: perl
    package TarotCard;

    use Moose;

    with 'Class::Avro::Role';

    has suit => (
        isa => 'Str',
        is => 'ro',
    );

    has number => (
        isa => 'Int',
        is => 'ro',
    );

    # and then later
    say TarotCard->avro_schema;

    my $card = TarotCard->new( suit => 'batons', number => 5 );

    say $card->suit, ' ', $card->number;


Ultimately, we also want the Avro to and fro to be compatible, such that we
could do full-Ouroboros and do:

    #syntax: perl
    # prints back the same schema, imported and exported
    say Class::Avro->new( schema => <<'END_SCHEMA' )->avro_schema;
    { 
        "type": "record",
        "name": "Dice",
        "fields": [
            { "name": "nbr_sides", "type": "int" },
            { "name": "color", "type": "string" }
        ]
    }
    END_SCHEMA

Sounds like a lot of stuff to do, isn't? But, as usual, the truth is not as
bacchanal as one would fear, but rather quite spartan. But let me show you...

## `Class::Avro` - The Class Generator

The goal of the class generator is rather simple: take a schema in, produce a
class with the corresponding attributes out. Keeping that in mind, the
implementation is no more complicated than:

<galuga_code code="perl">Avro.pm</galuga_code>

The slurping of the schema is nothing arcane: just a simple coercion to turn
the JSON string into a good ol' hashref.  The building of the class is only a
bit more involved. We create the new Moose class, slap on it the
`Class::Avro::Role`, and decorate it with all the fields provided by the
schema (with the right type constraint in bonus if we can map the Avro type
to the Moose equivalent).  Two itsy-bitsy utility functions (`deserialize` and
`avro_schema`) that are nothing but proxies for the created class are tacked
at the end and... that's it.

## `Class::Avro::Role` - The Core of the Beast

*Ah Ah,* you think, *this is where things get complicated!* Well, I hate to
say this, but you're about to get disappointed. Big time.

<galuga_code code="perl">Role.pm</galuga_code>

How can it be so short and so sweet? Well, mostly because I embraced laziness
and leveraged my dear pal [MooseX::Storage](cpan) to do all the
serializing/deserializing business. With that out of the way, creating the
Avro schema is mostly walking through the different attributes, seeing which
ones we don't want (thanks to the trait brought in by `MooseX::Storage`), and
convert the resulting structure into its JSON counterpart.

## Is That Really All?

To run the example code given above? Absolutely. 

Is `Class::Avro` CPAN-ready?
No, not quite. The current code only implement three of the basic types, and there
are more complex types (maps, unions and all that jazz) that would require a
little more work, but hardly more magic. But still, we already have a neat
little class and a role that at least allows us to, if not extensively, at
least babytalk with other Avro-abled applications. 

And that, I daresay, is darn nifty.

[avro]: http://avro.apache.org/docs/current/

