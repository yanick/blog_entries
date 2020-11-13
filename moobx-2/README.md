---
created: 2016-09-21
---

# MoobX(-Wing), part II: Tie Fighters

Welcome to the second part of my MoobX stream of codesciousness. 
In the [first installment](http://techblog.babyl.ca/entry/moobx),
we saw how to implement MobX-like reactive behaviors to Moose 
attributes. In this one, we'll ratchet up the insanity to the next
level, and muck up *any* variable we want. 

## No, Mister Bond, I expect you to tie

In our previous implementation, we had a relatively easy time because of all
the nice meta-tricks Moose give us.  How can we do the same thing with 
regular scalars, arrays and hashes?

How about using [tie](http://perldoc.perl.org/functions/tie.html)s? It's not
something that one uses very often but (or rather, because) it's incredibly powerful. Basically,
`tie`ing a variable binds it to a given object that implements its underlying
storage/access.

## First, the end-goal

Before diving in the mechanics, let's see what we are aiming for.
How about something like:


```
use 5.20.0;

use Data::Printer;

use MoobX;

observable my $first_name;
observable my $last_name;
observable my $title;

my $address = observer {
    join ' ', $title || $first_name, $last_name;
};

observable my @things;

say $address;  # nothing

$first_name = "Yanick";
$last_name = "Champoux";

say $address;  # Yanick Champoux

$title = 'Dread Lord';

say $address;  # Dread Lord Champoux
```

## Making something new with the old

While we are doing to act with new objects, the central part of Moobx we
wrote previously is still perfectly good and valid. So beside a few cosmetic
adjusments, we'll keep it wholesale.

```
package MoobX;

use 5.20.0;

use MoobX::Observer;
use MoobX::Observable;

our @DEPENDENCIES;
our $WATCHING = 0;

use Scalar::Util qw/ reftype refaddr /;
use Moose::Util qw/ with_traits /;
use Module::Runtime 'use_module';

use experimental 'signatures';

use parent 'Exporter::Tiny';

our @EXPORT = qw/ observer observable autorun /;

use Graph::Directed;

our $graph = Graph::Directed->new;

sub changing_observable($obs) {

    my @preds = $graph->all_predecessors( refaddr $obs );

    for my $pred ( @preds ) {
        my $info = $graph->get_vertex_attribute(
            $pred, 'info'
        );

        $info->clear_value;
    }
}

sub dependencies_for($self,@deps) {
    $graph->delete_edges(
        map { 
            refaddr $self => $_
        } $graph->successors(refaddr $self)
    );

    $graph->add_edges( 
        map { refaddr $self => refaddr $_ } @deps 
    );

    $graph->set_vertex_attribute(
        refaddr $_, info => $_ 
    ) for $self, @deps; 
}
```

For the declaration of observables, we'll use a few cabalistricks.
First we'll use a function prototype to grab the reference to its
argument so that we can do `observable @foo` instead
of `observable \@foo`.  And then we'll `tie` the passed
variable to some class we'll assemble right on the spot:

```
sub observable :prototype(\[$%@]) {
    my $ref = shift;

    my $type = reftype $ref;

    my $class = 'MoobX::'.( $type || 'SCALAR' );

    $class = with_traits( 
        map { use_module($_) }
        map { $_, $_ . '::Observable' } $class
    );

    if( $type eq 'SCALAR' ) {
        my $value = $$ref;
        tie $$ref, $class;
        $$ref = $value;
    }
    elsif( $type eq 'ARRAY' ) {
        my @values = @$ref;
        tie @$ref, $class;
        @$ref = @values;
    }
    elsif( not $type ) {
        my $value = $ref;
        tie $ref, $class;
        $ref = $value;
    }


    return $ref;

}
```

Why the ad-hoc composition there? Because I want to keep things nicely 
encapsulated: the classes `MoobX::<TYPE>` will strictly implement 
the functions required by the tie, while `MoobX::<TYPE>::Observable` will
implement the extras we need to make it, well, observable. Although I didn't
do it yet, it'll also allow for variables that could consume both an
observable and 
an observer role.

And talking of the observer, that's the other bit we need. And, why not?,
we'll throw in an `autorun` too:

```
sub observer :prototype(&) { MoobX::Observer->new( generator => @_ ) }
sub autorun :prototype(&)  { MoobX::Observer->new( autorun => 1, generator => @_ ) }
```

## The base MoobX::<type> classes

Here, nothing outrageous. Just a Moose-base
variation on the basic tie classes (see `Tie::StdScalar` at the bottom of 
[Tie::Scalar's
package](https://metacpan.org/source/RJBS/perl-5.24.0/lib/Tie/Scalar.pm) for an example). 


```
package MoobX::SCALAR; 

use Moose;

has value => (
    is     => 'rw',
    reader => 'FETCH',
    writer => 'STORE',
);

sub BUILD_ARGS {
    my( $class, @args ) = @_;

    unshift @args, 'value' if @args == 1;

    return { @args }
}

sub TIESCALAR { $_[0]->new( value => $_[1]) }

1;
```

Of course, a scalar variable is the most boring of the lot. Arrays and hashes
are not much more exciting, but they have more functions to implement. For the 
good of this proof of concept, I did part of the array class as well.


```
package MoobX::ARRAY;

use Moose;

has value => (
    traits => [ 'Array' ],
    is => 'rw',
    default => sub { [] },
    handles => {
        FETCHSIZE => 'count',
        CLEAR     => 'clear',
        STORE     => 'set',
        FETCH     => 'get',
        PUSH      => 'push',
    },
);

sub BUILD_ARGS {
    my( $class, @args ) = @_;

    unshift @args, 'value' if @args == 1;

    return { @args }
}

sub TIEARRAY { 
    (shift)->new( value => [ @_ ] ) 
}

1;
```

Oh, sorry, did I say I did it? I meant to say, just use delegation
to the attribute trait. Because being lazy is its own reward.

## The not-quite-as-base MoobX::<type>::Observable roles

Atop those main classes, we'll have the observable roles that add
the tallying and notifying logic around the setters and getters.

For scalars, it's short and sweet.

```
package MoobX::SCALAR::Observable;

use 5.20.0;

use Moose::Role;

before 'FETCH' => sub {
    my $self = shift;
    push @MoobX::DEPENDENCIES, $self if $MoobX::WATCHING;
};

after 'STORE' => sub {
    my $self = shift;
    MoobX::changing_observable( $self );
};

1;
```

For arrays, it's still not too bad. We just have to pay attention
to more ways the data can be set/accessed.

```
package MoobX::ARRAY::Observable;

use Moose::Role;

use experimental 'postderef', 'signatures';

use Scalar::Util 'refaddr';

before [ qw/ FETCH FETCHSIZE /] => sub {
    my $self = shift;
    push @MoobX::DEPENDENCIES, $self if $MoobX::WATCHING;
};

after [ qw/ STORE PUSH CLEAR /] => sub {
    my $self = shift;
    for my $i ( 0.. $self->value->$#* ) {
        next if tied $self->value->[$i];
        next unless ref $self->value->[$i] eq 'ARRAY';
        MoobX::observable( @{ $self->value->[$i] } );
    }
    MoobX::changing_observable( $self );
};

1;
```

There is also one small addition: we also set the values of the array
as observables themselves. Right now, I'm doing it in a rather uncouth
way, so don't look too closely, but the thing to take away is that
we'll be able to have arrays of arrays of arrays and we'll be able
to observe all changes, no matter how deep they happen.

(and yeah, I'm also being very sloppy for the case where values are
already tied. But that can be fixed and prettified with a little bit
of gilding code. I swear)


## The Observer class

The observer objects are... simple.

```
package MoobX::Observer;

use 5.20.0;

use Moose;

use overload 
    '""' => sub { $_[0]->value },
    fallback => 1;

use MooseX::MungeHas 'is_ro';

use Scalar::Util 'refaddr';
use experimental 'signatures';

has value => ( 
    builder   => 1,
    lazy      => 1,
    predicate => 1,
    clearer   => 1,
);

after clear_value => sub {
    my $self = shift;
    $self->value if $self->autorun;
};

has generator => (
    required => 1,
);

has autorun => ( is => 'ro', trigger => sub {
    $_[0]->value
});

sub dependencies($self) {
     map {
        $MoobX::graph->get_vertex_attribute( $_, 'info' );
      } $MoobX::graph->successors( refaddr($self) ) 
}

sub _build_value {
    my $self = shift;

    local $MoobX::WATCHING = 1;
    local @MoobX::DEPENDENCIES;

    my $new_value = $self->generator->();

    MoobX::dependencies_for( $self, @MoobX::DEPENDENCIES );

    return $new_value;
}

1;
```

The object has a generator (the function used to figure our the value),
and a `value` attribute that cache its result. We tally
the dependencies when we generate that value. Oh yeah, and we
add a smidgen of logic to have that value recomputed immediately
if our observer is flagged to be autorun.

## Try it, it's a riot

Aaaaand we're done. 

```
use Test::More;

use 5.20.0;

use Data::Printer;
use MoobX;

observable my $first_name;
observable my $last_name;
observable my $title;

my $address = observer {
    join ' ', $title || $first_name, $last_name;
};

is $address, ' ', "begin empty";

( $first_name, $last_name ) = qw/ Yanick Champoux /;

is $address => 'Yanick Champoux';

$title = 'Dread Lord';

is $address => 'Dread Lord Champoux';

done_testing;
```

Thanks to the magic of recursion, it works for changes that deep
in our data structures too.


``file-1.perl``

And, yes, we have also functions that autorun when changes are
detected.

``file-2.perl``

So, there we go. Brilliant? Insane? Or way beyond such mundane
human concepts? I'll let posterity judge. In the meantime, 
MoobX is living in its [GitHub repo](gh:yanick/moobx). Enjoy!


