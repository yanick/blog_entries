---
created: 2010-11-28
tags:
    - Perl
    - Catalyst
    - Catalyst::Plugin::MemoryUsage
    - Catalyst::Plugin::LeakTracker
    - Catalyst::Controller::LeakTracker
---


# Profiling Catalyst's Requests Memory Consumption

Thanks to [Catalyst::Stats](cpan), it's already a breeze to profile the
time taken by requests, and last week I found myself looking for the same kind 
of profiling ability for memory usage.  A quick look around made me discover
the dynamic duo [Catalyst::Plugin::LeakTracker](cpan) and 
[Catalyst::Controller::LeakTracker](cpan), but they were not
exactly what I'm looking for.  So... say *hi* to `Catalyst::Plugin::MemoryUsage`. 

The plugin is fairly simple, and (or so I hope) provides a good example of how
plugins can wiggle themselves at the different points of a request's
lifecycle. 

## Writing the Plugin

This plugin is all about capturing memory usage. To do that, I decided
to leverage [Memory::Usage](cpan).  So my first step was to add a
`memory_usage` attribute to the application's context object:

```perl
package Catalyst::Plugin::MemoryUsage;

use strict;
use warnings;

use namespace::autoclean;
use Moose::Role;

use Memory::Usage;

has memory_usage => (
    is => 'rw',
    default => sub { Memory::Usage->new },
);
```


Behavior-wise, I wanted to mirror what the time profiler
already does: sets a baseline when the request begins, records a milestone
for each private action that is hit, and reports the results when the
processing of the request is done.   

At first glance, that looks like a good challenge, but in reality it's much
easier to acheive than it sounds. Because the plugin is a Moose role, all we have to do is to figure out which 
functions Catalyst call during the lifetime of a request, and craft our
milestones around them.  Finding those functions was actually the trickiest
part of the operation, but a careful read of the
[Catalyst::Runtime](cpan) documentation, and a few sneaky peeks at other plugins 
managed to get me to a working state.

For the profiling's entry point, I piggy-backed on
`prepare()`, which creates the context object for the
new request:


```perl
around prepare => sub {
    my $orig = shift;
    my $self = shift;

    my $c = $self->$orig( @_ );

    $c->reset_memory_usage;
    $c->memory_usage->record( 'preparing for the request' );

    return $c;
};
```

For each private action, I tagged the milestone after `execute()`. It actually
gives me more granularity than desired, as we will see in the log sample
below, but that's okay. Better more than less, and if the additional
information begin to bother me, nothing prevents me of 
adding a little skipping logic in there later on.

```perl
after execute => sub {
    my $c = shift;

    $c->memory_usage->record( "after ". join " : ", @_ );
};
```

And, for the actually reporting, I grafted it after the
call to `finalize()`:

```perl
before finalize => sub {
    my $c = shift;

    $c->log->debug( 'memory usage of request', $c->memory_usage->report );
};
```

To that, we only have to add the function 
`reset_memory_usage()`, and our plugin is done.

```perl
sub reset_memory_usage {
    my $self = shift;

    $self->memory_usage( Memory::Usage->new );
}

1;
```

## Using the Plugin

Using the plugin is only a question of adding it to the list of plugins in 
the main `MyApp.pm` class of the application:

```perl
package MyApp;

use Catalyst qw/
    MemoryUsage
/;
```

With that single extra magic word, our logs will henceforth fill with yummy memory usage reports:

```
    [debug] memory usage of request
    time    vsz (  diff)    rss (  diff) shared (  diff)   code (  diff)   data (  diff)
        0  45304 ( 45304)  38640 ( 38640)   3448 (  3448)   1112 (  1112)  35168 ( 35168) preparing for the request
        0  45304 (     0)  38640 (     0)   3448 (     0)   1112 (     0)  35168 (     0) after Galuga::Controller::Root : _BEGIN
        0  45304 (     0)  38640 (     0)   3448 (     0)   1112 (     0)  35168 (     0) after Galuga::Controller::Root : _AUTO
        0  46004 (     0)  39268 (     0)   3456 (     0)   1112 (     0)  35868 (     0) after Galuga::Controller::Entry : entry/index
        0  46004 (     0)  39268 (     0)   3456 (     0)   1112 (     0)  35868 (     0) after Galuga::Controller::Root : _ACTION
        1  47592 (  1588)  40860 (  1592)   3468 (    12)   1112 (     0)  37456 (  1588) after Galuga::View::Mason : Galuga::View::Mason->process
        1  47592 (     0)  40860 (     0)   3468 (     0)   1112 (     0)  37456 (     0) after Galuga::Controller::Root : end
        1  47592 (     0)  40860 (     0)   3468 (     0)   1112 (     0)  37456 (     0) after Galuga::Controller::Root : _END
        1  47592 (     0)  40860 (     0)   3468 (     0)   1112 (     0)  37456 (     0) after Galuga::Controller::Root : _DISPATCH
```

Need more measuring points in the report? Peppering the actions' code with a
few

```perl
    $c->memory_usage->record( "finished running some big chunk o' code" );
```

will do the trick.

## Yeah, Yeah, Now Gimme the Code!

As usual, the code is available on
[GitHub](http://github.com/yanick/Catalyst-Plugin-MemoryUsage), and should hit
CPAN in a few days, once I had time to distributionify it. Enjoy!
