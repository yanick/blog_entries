---
created: 2017-10-22
---

# New and Improved: Promises v0.97

By the time you read this, v0.97 of [Promises](cpan:Promises)
will have made its way to CPAN. This release has some fixes, and two new
utility functions that might, just might, pique your curiosity.

## `collect_hash()`

This is one a very thin layer of sugar atop 
`collect()`. Very thin, yet very delicious.

It's meant to address the cases where we want to wait for 
a bunch of asynchronous tasks before doing something. Using `collect()`,
that's something that would be done like the following:

```perl

use Promises qw/ collect /;

# the fetch_* subs return promises

collect(
    fetch_account(),
    fetch_transactions(),
    '2017-10-22'
)->then(sub{
    my( $account, $transactions, $date ) = @_;

    my $balance = fetch_balance( $account, $date );

    collect( $account, $transactions, $date, $balance );
})->then(sub{
    my ( $account, $transactions, $date, $balance ) = @_;

    ...
});


```

It's not bad, but as the list of collected promises grow, we
have to remember a long list of ordered parameters. which is... okay. With
`collect_hash()`, we can turn that long list of arguments into a hash.

```perl

use Promises qw/ collect_hash /;

collect(
    account      => fetch_account(),
    transactions => fetch_transactions(),
    date         => '2017-10-22'
)->then(sub{
    my %arg = @_;

    $arg{balance} = fetch_balance( $account, $date );

    collect_hash( %arg );
})->then(sub{
    my %arg = @_;

    ...
});

```

Or, even better:

```perl

use Promises qw/ collect_hash /;

# the fetch_* subs return promises

my %promises = (
    account      => fetch_account(),
    transactions => fetch_transactions(),
    date         => '2017-10-22',
);

$promises{balance} = collect_hash(
    %promises{qw/ account date /}
)->then(sub{
    my %arg = @_;
    fetch_balance(@arg[qw/ account date /])
});

collect(%promises)->then(sub{
    my %arg = @_;

    ...
});

```

Under the hood it's not much, really, just a mapping that auto-expand
the arrayrefs that `collect()` is returning. But you know what they say:
it's the little things.

## `timeout()`

Let's be honest: as soon as we launch asynchronous jobs like so 
many homing pigeons, we run the chance that some won't come back.
And as soon as this matters, we have to implement timeouts. 


Since it's
something that we do over and over again, I decided to be bold and just
bake it into the `Promise` objects. As long as the Promises' configured 
backend supports it
(and right now all of them, with the exception of the default non-asynchronous
backend, do), we can plop a `timeout()` whenever impatience is required.
`timeout()` will return a new promise that will percolate the success or
failure
of the original promise if it terminates within the alloted time, or will
be rejected once the buzzer goes off.

```perl

use Promises backend => [ 'IO::Async' ];
use Promises 'deferred';

my $promise = fetch_it();

$promise->timeout( 60 )->then(
    sub { print "we fetched within the time!"   },
    sub { print "fetch failed, or we got bored" }
);

```



