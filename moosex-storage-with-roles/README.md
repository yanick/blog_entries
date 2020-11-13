---
created: 2015-12-21
---

# Making MooseX::Storage Play Nice with Runtime Roles 

[](cpan:MooseX-Storage) is an essential part of one's Moose toolbox that 
provides a way to easily serialize Moose objects into whatever format you want
(YAML, JSON, Sereal, whatev) and back. And because I can never leave good
enough alone, I just released two modules that can make it even more
versatile. Here, lemme show you. 

## Trust what it says on the tin

The usual way to deserialize objects with `MooseX::Storage`
is to call the `unpack` (or `thaw`, or `load`) method of the target's class.
For example, assuming we have the class `SpaceCowboy`:


```perl
package SpaceCowboy {

    use Moose;
    use MooseX::MungeHas 'is_ro';
    use MooseX::Storage;

    with Storage();

    has name => ();
    has temperament => ();
}
```

We can turn a space cowboy into a frozen statue and dethaw him via

```perl
my $browncoat = SpaceCowboy->new( name => 'Malcolm', temperament => 'dour' );

my $struct = $browncoat->pack;
    # $struct = {
    #    __CLASS__     "SpaceCowboy",
    #    name          "Malcolm",
    #    temperament   "dour"
    # }

my $new_instance = SpaceCowboy->unpack($struct);
```

(Ah! I bet you thought I was going to use a different example for that one,
didja?)

That's nice, but if we have a serializing pipeline where we have different
classes, it's a little bit roundabout to manually check for that `__CLASS_` attribute
to know which class to use:

```perl
    use Class::Load qw/ load_class /;
    my $obj = load_class( $struct->{'__CLASS__'} )->unpack($struct);
```

So, yeah, I wrote [](cpan:MooseX::Storage::Base::SerializedClass) which does
that dance for us, by looking at that `__CLASS__` itself and figuring
everything out:

```perl
use MooseX::Storage::Base::SerializedClass qw/ moosex_unpack /;

my $obj = moosex_unpack($struct);
```

## Dealing with runtime roles

Here comes the main attraction.  While the previous section doesn't really
add anything -- just make things a tad easier, here I addressed a blind spot
that `MooseX::Storage` had: runtime-added roles.

For example, let's add a role to go with our space cowboy:

```perl
package Captain {

use Moose::Role;
use MooseX::MungeHas 'is_ro';

has ship => ();

}
```

Nothing fancy so far. Let's us make ourselves a captain Tightpants:

```perl

use Moose::Util;

my $browncoat = with_traits( 'SpaceCowboy', 'Captain' )->new(
    name        => 'Malcolm',
    temperament => 'dour',
    ship        => 'Serenity',
);

my $struct = $browncoat->pack;
    # {
    #     __CLASS__     "Moose::Meta::Class::__ANON__::SERIAL::1",
    #     name          "Malcolm",
    #     ship          "Serenity",
    #     temperament   "dour"
    # }
```

Ooops. Because we've composed our class at runtime, it's an anonymous
mash of `SpaceCowboy` and `Captain`. MooseX::Storage won't know
how to put things back together again, and even our new `moosex_unpack`
won't help, because the information is not there. We're kinda screwed.

But we don't need to be. All the information about roles is there in the meta
layer of the class. So all we need to have an MooseX::Storage engine
that knows where to dig, and put the information in the serialized 
structure. And that's exactly what my new
[](cpan:MooseX::Storage::Engine::Trait::WithRoles) does.

```perl
package SpaceCowboy {

    use Moose;
    use MooseX::MungeHas 'is_ro';
    use MooseX::Storage;

    with Storage( base => 'SerializedClass', traits => [ 'WithRoles' ] );

    has name => ();
    has temperament => ();
}

    # Captain stays the same

use Moose::Util qw/ with_traits /;
use MooseX::Storage::Base::SerializedClass qw/ moosex_unpack /;

my $browncoat = with_traits( 'SpaceCowboy', 'Captain' )->new(
    name        => 'Malcolm',
    temperament => 'dour',
    ship        => 'Serenity',
);

my $packed = $browncoat->pack;
    # \ {
    #    __CLASS__     "SpaceCowboy",
    #    name          "Malcolm",
    #    __ROLES__     [
    #        [0] "Captain"
    #    ],
    #    ship          "Serenity",
    #    temperament   "dour"
    # }

my $obj = moosex_unpack($packed);

say "I am ", $obj->name, 'captain of the ', $obj->ship;

```

And now, I just wish there was something in the room to say "that's so cool".
Just so that I could grin, and drily say: "I know."
