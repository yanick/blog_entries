---
title: Test-driving Reflex
url: reflex
format: markdown
created: 2012-05-17
tags:
    - Perl
    - Reflex
---

At *$work* we have a need for a little job daemon that would poll jobs
and process them. If there was
only one kind of job involved, the solution could be nothing more complicated
than

    #syntax: perl
    while ( my @jobs = poll_jobs() ) {
        process( $_ ) for @jobs;
        sleep $a_wee_bit;
    }

But there are more than one type of job, so the solution that we need
will have to be a little more complex. In fact, that's something that
typically can be dealt with with event-drived programs. As I don't dabble often
with that kind of stuff, I jumped on the occasion to play around a little
bit. Perl doesn't lack in event-based systems, [POE](cpan) and
[AnyEvent](cpan) are two big names there, but I decided to
have fun with [Reflex](cpan), a [Moose](cpan)-based 
system built on top of `POE`. 

To get to my goal, I decided that I would have a generic `Poller` class. For
each type of job to monitor and run, I will create a different object with
parameters to tell it how often to poll, how to poll and what to do with the
stuff it poll. Sounds good? Perfect, then let's go.

First things first, let's declare the class and import our favorite logging
role:


    #syntax: perl
    package Poller;

    use 5.10.0;

    use strict;
    use warnings;

    use Moose;

    extends 'Reflex::Base';

    with 'MooseX::Role::Loggable';

    has '+log_to_stdout' => (
        default => 1,
    );

We also want a queue where to put the jobs that we poll until
we have time to process them

    #syntax: perl
    has queue => (
        is => 'ro',
        traits => [ 'Array' ],
        handles => {
            add_to_queue => 'push',
            shift_queue  => 'shift',
            queue_size   => 'count',
        },
    );

And now, event stuff. For that, we're going to use
<cpan type="module">Reflex::Role::Interval</cpan>:


    #syntax: perl
    has polling_interval => (
        is      => 'ro',
        default => 5,
    );

    has [ qw/ polling_auto_start / ] => (
        is      => 'ro',
        default => 1,
    );

    has process_interval => (
        is      => 'ro',
        default => 0,
    );

    has [ qw/ 
            process_auto_start 
            process_auto_repeat 
            polling_auto_repeat 
    / ] => (
        is => 'ro',
        default => 0,
    );

    has [ qw/ polling_function process_function / ] => (
        is       => 'ro',
        required => 1,
    );

    with 'Reflex::Role::Interval' => {
        att_interval      => $_."_interval",
        att_auto_start    => $_."_auto_start",
        att_auto_repeat   => $_."_auto_repeat",
    } for qw/ polling process /;

A little verbose, but there is nothing very arcana in there; just the
declaration of all the settings related to the two work loops (polling and
processing) that we need.

The good news, though, is that after this, we only need set the callbacks for
both work loops:

    #syntax: perl
    sub on_polling_interval_tick { $_[0]->polling_function->(@_) }
    sub on_process_interval_tick { $_[0]->process_function->(@_) }

Since we are feeling fancy and don't want to poll when we still have work
to do, we decide what we do next based on the status of the job queue:


    #syntax: perl
    after [ qw/ 
        on_process_interval_tick 
        on_polling_interval_tick 
    / ] => sub {
        my $self = shift;

        my $method = join '_', 
            'repeat', 
            ( $self->queue_size ? 'process' : 'polling' ), 
            'interval';

        $self->$method;
    };

And we are done.

    #syntax: perl
    Poller->meta->make_immutable;
    
    1;

With this, creating our daemon that poll different jobs is pleasantly
straight-forward:

    #syntax: perl
    my $foo = Poller->new(
        polling_function => sub { 
            state $i = 0;
            poll(@_);
        },
        process_function => \&process,
    );

    my $bar = Poller->new(
        polling_interval => 2,  # a little faster
        polling_function => sub { 
            state $i = 'a';
            poll(@_);
        },
        process_function => \&process,
    );

    sub poll {
        my $self = shift;

        my @new = map { ++$i } 1..rand 5;
            
        $self->log( "polling " . join ', ', @new );
        $self->add_to_queue(@new);
    }

    sub process {
        my $self = shift;

        my $item = $self->shift_queue or return;

        $self->log( "processing $item" );
    }

    Reflex->run_all;

A test run to convince ourselves that everything works as advertised:

    #syntax: bash
    $ perl daemon.pl
    [5286] polling b, c
    [5286] processing b
    [5286] processing c
    [5286] polling d, e, f
    [5286] processing d
    [5286] processing e
    [5286] processing f
    [5286] polling 1, 2, 3
    [5286] processing 1
    [5286] processing 2
    [5286] processing 3
    [5286] polling g, h, i, j


Bottom-line? `Reflex` is one heck of a shiny toy. Caveat, though for the
potential emptor: it's still fairly beta and the documentation does not always
exactly reflect the current implementation.  But it's definitively something
worth to keep on the radar.
