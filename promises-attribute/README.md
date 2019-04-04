---
created: 2017-05-05
---

# Promises, promises...

A quick one.

Been doing things with [Promises](cpan:Promises) again.
My experiment is on [this
branch](https://github.com/yanick/promises-perl/tree/attribute).

First, I meddled with `collect()` such that it can also take
in non-promises (that are simply wrapped in arrayrefs and passed through).

```perl

    use Promises qw/ collect deferred /;

    my $p = deferred;

    collect(
        $p,
        'and that'
    )->then(sub{ 
        print join ' ', map { @$_ } @_;
    });

    $p->resolve('this');
    # => prints 'this and that'
```

And then I created `Promises::Attribute` that allow to 
auto-convert a function into a promise. 

```

use parent 'Promises::Attribute';

sub add :Promise { $_[0] + $_[1] }

add( 1, 2 )->then(sub{ print @_ });
# => prints '3'

```

Not only that, but it'll also detect any promise passed
as a parameter, and will wait until those are resolved before
running the node.

```perl
use experimental 'signatures';

use Promises 'deferred';
use parent 'Promises::Attribute';

sub shall_concat :Promise ($thing, $other_thing) {
    join ' ', $thing, $other_thing;
}

my @promises = map { deferred } 1..2;

my @results = (
    shall_concat( @promises ),
    shall_concat( 'that is', $promises[1] ),
    shall_concat( 'this is', 'straight up' ),
);

say "all results are promises";

$_->then(sub { say @_ } ) for @results;
# => prints 'this is straight up'

say "two results are still waiting...";

$promises[1]->resolve( 'delayed' );
# => prints 'that is delayed'

say "only one left...";

$promises[0]->resolve( 'finally the last one, that was' );
# => prints 'finally the last one, that was delayed'
```


Enjoy!

(told ya it was a quick one)
