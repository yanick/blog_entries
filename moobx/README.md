---
created: 2016-09-19
---

# MoobX (MobX + Moose): part I

This is a raw blurping of the code I've been thinking about for the last
few weeks. I'll doubtlessly revisit this MoobX series, sanitize it 
(in all the senses of the word) and re-publish it, but right now
I'm having too much fun not to share.

So, yeah, I've spent quite a lot of time familiarizing myself with the
JavaScript ecosystem these last few months. Which mostly involves
trying all the  frameworks the cool kids are using
and see what I like and what makes
me whimper. And as I am trying those frameworks, I'm always
thinking back to how they would map to the Perl world. Because nothing
makes you understand something like trying to rebuild it from scratches.

Anyway, one of the frameworks I tried was
[Redux](https://github.com/reactjs/redux), because a friend told me it was
the bee's knees. I poked around. I learned. A
Perl prototype was created. A [blog entry](https://iinteractive.com/notebook/2016/09/09/pollux.html) was written. All was good and I went back to my friend
to 
show off a wee bit.

"Redux? That old thing? Geeez... You should really switch to 
[MobX](https://github.com/mobxjs/mobx). It's the cat's pajama."

... JavaScript. Thou are not false, but thou are bloody frickin' fickle...

Nonetheless, nursing the whiplash inflicted by this mad framework carousel,
I checked out MobX. And it is indeed pretty cool, and quite different from
Redux.

What MobX does is to have variables change when the variables they
depend on are modified. Of course, reactive and event-driven 
programming are not exactly new. But the special thing this framework does
is that it figure out all by itself which variables depend on which others.
All we have to do is to indicate which variables should be observed for
potential changes, which variables will be built on those (without mentioning
the exact relationships), and things take care of themselves. Something like:

```
    observable my $first_name = 'Yanick';
    observable my $last_name = 'Champoux';
    observable my $title;

    my $address = observer {
        join ' ', $title || $first_name, $last_name;
    };

    say $address;  # 'Yanick Champoux'

    $title = 'Dread Lord';

    say $address;  # 'Dread Lord Champoux'
```

How does it do it? Magic? No. Cleverness. What it does is build a 
dependency graph of the different observers and observables. And it does
that by having the observable variables report when they are accessed.
That way, when an observer computes its value, it also check which 
observable were used, and remember that as its dependencies. When an
observable subsequently change, we can find back in the graph all
the observers that depends on it, and mark then as needing to be
recomputed.

Now, I already tweeting something to the effect that I
had a Moose-based port of MobX in mind. I kinda lied there. I don't have such
a thing in mind. 

I have two versions.

For this first blog entry, I'll present the first version I came up with.
It has a fairly limited scope, it doesn't recursively watch
observable data structures and only work with object attributes, but it
still has interesting properties while having a pretty darn small footprint.

## What we want

First thing, let's write how we'd like to have the end-code to look like.

To stick with the simple example of addressing a person, let's assume we have
a set of two inter-related classes:

```
package Person {

    use Moose;

    use experimental 'signatures';

    has address => (
        is      => 'ro',
        traits  => [ 'Observer' ],
        lazy    => 1,
        clearer => 'clear_address',
        default => sub($self) {
            join ' ', $self->title || $self->name->first, $self->name->last;
        },
    );

    has name => ( is => 'ro' );

    has title => (
        traits => [ 'Observable' ],
        is => 'rw',
    );
}

package Name {

    use Moose;

    has [ qw/ first last /] => (
        is => 'rw',
        traits => [ 'Observable' ],
    );

}
```

Just run-off-the-mill stuff, plus the addition of `Observable` and `Observer`
traits. With that, the holy grail would be to then be able to do

```
my $foo = Person->new( name => Name->new( first => 'Yanick', last => 'Champoux' ) );

say $foo->address;  # Yanick Champoux

$foo->title( 'Dread Lord' );

say $foo->address;  # Dread Lord Champoux
```

So... Let's do this.

## Observer

First on the line: the `Observer` trait. For this one, we want to figure out
which are the attributes it depends on for its own value. Basically, before we
compute its value, we want to say "okay, observables, if you are accessed,
raise your hand", compute the value, and see which hands are waving at us.

Sounds simple? It is actually fairly simple. What we do is surround the
attribute `default`  coderef with the tallying stuff.

```
package Observer {
    use Moose::Role;

    before _process_options => sub {
        my( $class, $name, $params ) = @_;

        my $default = $params->{default};

        $params->{default} = sub {
            local $MoobX::WATCHING = 1;
            local @MoobX::DEPENDENCIES;

            my $self = shift;

            my $new_value = $default->($self);

            MoobX::dependencies_for( [ $self => $name ], @MoobX::DEPENDENCIES );

            return $new_value;
        };
    };
}
```

Before we do our computations, we flick MoobX in watch mode and localize the
`DEPENDENCIES` list (that's important when we'll have recursive
observers/observables). After, we record those dependencies in our graph. Oh,
and
those dependencies are of the form `[ $object, $attribute_name ]`.


## Observable

And now, the flip-side of the `Observer`. And it's not any harder. What we
want is for the observable to raise its hand when it's accessed (if somebody
is watching) and let its dependent observers know when it's modified. 

```
package Observable {
    use Moose::Role;

    after initialize_instance_slot => sub {
        my( $self, $meta, $instance, $params ) = @_;

        $instance->meta->add_before_method_modifier( $self->get_read_method, sub {
            push @MoobX::DEPENDENCIES, [ $instance, $self->name ] if $MoobX::WATCHING;
        });

        $instance->meta->add_after_method_modifier( $self->get_write_method, sub {
                MoobX::changing_observable( [ $instance, $self->name ] );
        });
    };
}
```

Mind you, I'm cheating a little bit here as, to name one, I don't cover the case where we
clear the attribute. But for this proof-of-concept, hooking into the setter
and getter will be good enough.

## The dependency graph

And now we need the bit that connect the two sides: the dependency graph.
At the core, I'll be leveraging the power of [Graph](cpan:release/Graph).

```
package MoobX {
    our @DEPENDENCIES;
    our $WATCHING = 0;

    use Scalar::Util 'refaddr';
    use experimental 'signatures';

    use Graph::Directed;

    our $graph = Graph::Directed->new;
```

What we need is one function to record the dependencies,

```
sub node_name($node) { join '!', @$node }

sub dependencies_for($self,@deps) {

    # always start clean
    $graph->delete_edges( map { 
            node_name( $self ) => $_
        } $graph->successors(node_name($self))
    );

    $graph->add_edges( 
        map { node_name($self) => node_name($_) } @deps 
    );

    $graph->set_vertex_attribute( 
        node_name($_), info => $_ 
    ) for $self, @deps; 
}
```

and one function to figure out which observers are affected by a changing
observable,

```
sub changing_observable($obs) {
    my @preds = $graph->all_predecessors( node_name($obs) );

    for my $pred ( @preds ) {
        my $info = $graph->get_vertex_attribute( $pred, 'info' );

        my( $obj, $attr ) = @$info;
        my $clearer = $obj->meta->get_attribute($attr)->clearer;
        $obj->$clearer;
    }

}
```

Note that we don't immediately recompute the observers affected by the changed
observables. We merely clear their value, so that the next time they are
accessed, the
default coderef will be invoked and computed with the fresh new observables
(and its new dependencies recorded, natch).

## Drum roll please...

And that's all that is required to get us a barebone MobX lookalike. The real
code has one more function that I didn't put above:

```
package Observer {

    ...;

    after initialize_instance_slot => sub {
        my( $self, $meta, $instance, $params ) = @_;

        $instance->meta->add_method(
            'dependencies_' . $self->name, sub {
                map { $MoobX::graph->get_vertex_attribute($_, 'info') }
                $MoobX::graph->successors( MoobX::node_name([ $instance, $self->name]));
            }
        );
    };
```

That's to add a `dependencies_<attribute>` method to the object, to be able to
peek into the dependencies. 

And that's that. It's quick, it's minimal, but by Joves, it works.

```
my $foo = Person->new( name => Name->new( first => 'Yanick', last => 'Champoux' ) );

say $foo->address;  # Yanick Champoux

$foo->title( 'Dread Lord' );

say $foo->address;  # Dread Lord Champoux

for my $dep ($foo->dependencies_address ) {
    my( $obj, $attr ) = @$dep;
    say $obj . '->' . $attr, ' = ', $obj->$attr;
}
# Name=HASH(0x3f3c028)->last = Champoux
# Person=HASH(0x3f57138)->title = Dread Lord
```

## To be continued...

This is all nice and stuff, but what about regular variables? And deep observable data
structures? Can we do something for those?

Well, but yes, yes we can. That, however, will require the use of some... aaaah... blacker arts. Not that I want to scare you, but `tie`s might get involved. So, stay tuned! ... if you dare.
