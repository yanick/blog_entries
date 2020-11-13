---
created: 2011-01-01
tags:
    - Perl
    - Log::Dispatchouli
    - Data::Localize
---

# Having fun with logging and I18N

I must confess, that [game I'm leasurely working
on](http://babyl.dyndns.org/techblog/entry/perl-in-space) is nothing but a big
fat excuse to dabble with fun bits of technology that I don't get to touch 
with my usual projects.  And in that optic, yesterday I fooled around with 
logging and internationalization stuff.

... Yes, I know. I'm using a game as a pretext to work on logging and I18N. 
I'm ashamed of myself. But aaanyway, let's see what I got to discover.

## Log::Dispatchouli - smells good, works even better

I don't think I'm making much of a mistake by saying that 
the two king modules in the Perl world for logging are
[Log::Log4perl](cpan) and [Log::Dispatch](cpan).
[Log::Dispatchouli](cpan) is built on top of the latter, 
and is meant to simplify its use for the usual use cases.
It was on my radar before, but I never got around using it.
[Rjbs' first advent entry](http://advent.rjbs.manxome.org/2010/2010-12-01.html),
however, whet back my appetite to play with it, and my little game is 
giving me a perfect excuse to do so.

Within the context of the game, I want to use logging not for
the application itself, but to report to the players 
the events that happen during a round. Consequently, I would like
all log entries to be identified with the fleet / ship / crew member that 
issued it.  Fortunately, `Log::Dispatchouli` proxy logging is there 
to do exactly that.

From the outside of the object, it's all very simple: just pass the 
main `$logger` for the whole application:

```perl
my $log = Log::Dispatchouli->new({
        ident     => 'game',
        to_stdout => 1,
        to_self   => 1,
});

my $ship = Ship->new(
    fleet  => 'StarFleet',
    name   => 'USS Rakudo',
    logger => $log,
);
```

From within the object, it's not much harder. At the end of the object
creation phase I personalize the logger for this specific
fleet and ship, and I throw in a few logging help functions:

```perl
package Ship;

use Log::Dispatchouli;

use Moose;

has [ qw/ fleet name / ] => ( 
    is       => 'ro',
    required => 1 
);

has logger => (
    is       => 'rw',
    required => 1,
);

after BUILDALL => sub {
    my $self = shift;

    $self->logger( $self->logger
        ->proxy( { proxy_prefix => '[' . $self->fleet . '] ' } )
        ->proxy( { proxy_prefix => '[' . $self->name .'] ' } ) 
    );

};

has max_thrust => ( is => 'ro', default => 10 );

sub internal_log {
    my ( $self, $crew, @message ) = @_;

    $self->logger->log( { prefix => "[$crew] " }, @message );
}

sub engineer_log {
    my ( $self, @msg ) = @_;
    $self->internal_log( 'engineer', @msg );
}
```

And now if we want the engineer to say something, we can simply use `engineer_log`:

```perl
sub engage_thrusters {
    my $self   = shift;
    my $thrust = shift;

    if ( $thrust > $self->max_thrust ) {
        $self->engineer_log( [ "Thrust reduced to the engine maximum (%s)", $self->max_thrust ] );
        $thrust = $self->max_thrust;
    }

    # thrust code goes here
}
```

Et voilà, we have logging. The code

```perl
$ship->engage_thrusters( 12 );
```

produces the log output

```
[22008] [StarFleet] [USS Rakudo] [engineer] Thrust reduced to the engine maximum (10)
```

Oh, and notice the use of the parameter `to_self` in the creation of the
logger? That's to tell it to keep a copy of the logs, which can be accessed
with the method `events()`. So that latter I can do, for example:

```perl
my @starfleet_log = 
    grep { $_->[1] eq 'StarFleet' } 
    map  { [ m#(?:\G|^)\[([^]]+)\] #g, $' ] }
    map  { $_->{message} } 
         @{ $log->events };
```

Not that I want to use that verbatim, mind you, as the use of<code>$`</code>
is going to slow down everything, but you get the idea: I can
still have access to the log within the application without having
to play "re-read the log file" game.


## Data::Localize - let's make our crew talk funny

Now that we have our crew talking to us, it'd be nice 
to give them some personality. After all, StarFleet engineers
aren't expected to talk like their Klingon counterparts, right?

To do that, I've resorted to [Data::Localize](cpan), 
which for me was a little easier to get working than 
[Locale::Maketext::Simple](cpan).  To add the functionality
to the `Ship` class, I've added the translator to the ship's computer grid:


```perl
has loc => ( 
    is => 'ro',
    default => sub {
        my $loc = Data::Localize->new;
        $loc->add_localizer( 
            class      => 'Namespace',
            namespaces => [ 'Ship::Lingo' ],
        );
        $loc->auto(1);
        return $loc;
    },
    handles => [ qw/ localize / ],
);
```

Without forgetting to initialize it to the right language at 
building time:

```perl
after BUILDALL => sub {
    my $self = shift;

    $self->logger( $self->logger
        ->proxy( { proxy_prefix => '[' . $self->fleet . '] ' } )
        ->proxy( { proxy_prefix => '[' . $self->name .'] ' } ) 
    );

    $self->loc->set_languages( $self->fleet );
};
```

And, to make it transparent for the rest of the code, I intercept the
messages sent to the log and change them before [String::Flogger](cpan)
does its magic:

```perl
sub internal_log {
    my ( $self, $crew, @message ) = @_;

    for ( @message ) {
        if ( ref $_ eq 'ARRAY' ) {
            $_->[0] = $self->localize( $_->[0] );
        }
        elsif ( ! ref $_ ) {
            $_ = $self->localize( $_ );
        }
    }

    $self->logger->log( { prefix => "[$crew] " }, @message );
}
```

All we have to do is to create the lexicon classes, which hold nothing 
but a big dump hash (I've tried to go the way of the `po/mo` files, but
I still have to get the hang of the creation/update process of those
puppies):

```perl
package Ship::Lingo::StarFleet;

our %Lexicon = (
    "Thrust reduced to the engine maximum (%s)" 
        => q{She canna go that high, capt'n! I'm giving you %s.},   
);

1;
```

And that's all there is to it. If we run

```perl
my $ship = Ship->new(
    fleet  => 'StarFleet',
    name   => 'USS Rakudo',
    logger => $log,
);

my $other_ship = Ship->new(
    fleet  => 'Klingon',
    name   => 'HMS Vista',
    logger => $log,
);

$ship->engage_thrusters( 12 );
$other_ship->engage_thrusters( 12 );
```

We'll get:

```
[22312] [StarFleet] [USS Rakudo] [engineer] She canna go that high, capt'n! I'm giving you 10.
[22312] [Klingon] [HMS Vista] [engineer] Qovpatlh! The ship can not go beyond 10.
```

