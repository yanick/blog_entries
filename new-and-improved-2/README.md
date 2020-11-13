---
url: new-and-improved-moosex-role-buildinstanceof
created: 2011-11-10
tags:
    - Perl
    - New and Improved
    - MooseX::Role::BuildInstanceOf
    - DBIx::Class::DeploymentHandler
---

# New & Improved: MooseX::Role::BuildInstanceOf

<div style="float: right; padding: 5px;">
<img src="__ENTRY_DIR__/val_approuve.png" alt="New and Improved!" width="150"/>
</div>

Okay, so [MooseX::Role::BuildInstanceOf](cpan) is not one of my modules.
And while I submited the patch, the feature itself was born out of 
[fREW](http://search.cpan.org/~frew/)'s
[DBIx::Class::DeploymentHandler](cpan). So, in all this, my role was
at best to be the pollinator agent between two beautiful flowers. But, hey,
it's not like a little bit of  noise is going to hurt any of the involved
parties, sooo... let's see what the buzz's about.

## Insanely Quick Intro to MooseX::Role::BuildInstanceOf

[MooseX::Role::BuildInstanceOf](cpan) is a Moose module
that aims at reducing the amount of boilerplate code needed 
for dealing with sub-objects. It's a little meta-scary at first,
but once one understanding settles in, it's humongously handy.
Without going into the details, with that module, you can turn that
chunk of code:

```perl
package MyShip;

    use Moose;

    has engine => (
        is => 'ro',
        lazy_build => 1,
    );

    has engine_args => (
        isa => 'ArrayRef',
        is => 'ro',
    );

    sub _build_engine {
        my $self = shift;

        return MyShip::Engine->new(
            @{ $self->engine_args || [ fuel => 100 ] },
            max_speed => 10,
        );
    }

    1;
```

into

```perl
package MyShip;

    use Moose;

    with 'MooseX::Role::BuildInstanceOf' => {
        target => '::Engine',
        args => [ fuel => 100 ],
        fixed_args => [ max_speed => 10 ],
    };

    1;
```

Both versions will do just what you think it will do when you write

```perl
# damned Ferengies never fill up the tank
my $warbird = MyShip->new( engine_args => [ fuel => 20 ] );
```

There is a *lot* more to [MooseX::Role::BuildInstanceOf](cpan) than that,
but we can agree that it's already pretty sweet.

## So, What's New?

In the last few days, I've been deep-diving into 
[DBIx::Class::DeploymentHandler](cpan).  Within that
distribution, fREW kinda rolled out a module similar to 
[MooseX::Role::BuildInstanceOf](cpan): 
[DBIx::Class::DeploymentHandler::WithApplicatorDumple](http://search.cpan.org/~frew/DBIx-Class-DeploymentHandler-0.001005/lib/DBIx/Class/DeploymentHandler/WithApplicatorDumple.pm).
It is acknowledged in the source of the module that its implementation is a
little on the ghetto side, and should probably be refactored with
[Role::subsystem](cpan) or, *ah AH!*,
[MooseX::Role::BuildInstanceOf](cpan).

Me, eternal meddler, couldn't
resist looking into that, and quickly saw that `WithApplicatorDumple` had
something that `MX::R::BIO` was missing: the ability to automatically
push down to the sub-objects some attributes of the main object. Very handy,
that. So I cracked my knuckles, went to work... and by now the code


```perl
package MyShip;

    use Moose;

    has captain => ( is => 'ro' );

    has intercom => ( 
        is => 'ro', 
        isa => 'Log::Dispatchouli',
        default => sub {
            ...
        },
    );

    has coordinates => (
        is => 'ro',
        isa => 'MyShip::Coord',
        default => sub {
            MyShip::Coord->new( 0, 0 );
        },
    );

    has engine => (
        is => 'ro',
        lazy_build => 1,
    );

    has engine_args => (
        isa => 'ArrayRef',
        is => 'ro',
    );

    sub _build_engine {
        my $self = shift;

        return MyShip::Engine->new(
            @{ $self->engine_args || [ fuel => 100 ] },
            max_speed => 10,
            coordinates => $self->coordinates,
            bridge_monkey => $self->captain,
            intercom => $self->intercom->proxy({ proxy_prefix => 'Engine' });
        );
    }

    1;
```

can all be replaced by

```perl
package MyShip;

    use Moose;

    has captain => ( is => 'ro' );

    has intercom => ( 
        is => 'ro', 
        isa => 'Log::Dispatchouli',
        default => sub {
            ...
        },
    );

    has coordinates => (
        is => 'ro',
        isa => 'MyShip::Coord',
        default => sub {
            MyShip::Coord->new( 0, 0 );
        },
    );

    with 'MooseX::Role::BuildInstanceOf' => {
        target => '::Engine',
        args => [ fuel => 100 ],
        fixed_args => [ max_speed => 10 ],
        inherited_args => [
            'coordinates',
            {
                bridge_monkey => 'captain',
                intercom => sub {
                    my $self = shift;
                    $self->intercom->proxy({ proxy_prefix => 'Engine' });
                },
            }
        ],
    };

    1;
```

Nifty, isn't?
