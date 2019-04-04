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

has queue => (
    is => 'ro',
    traits => [ 'Array' ],
    handles => {
        add_to_queue => 'push',
        shift_queue  => 'shift',
        queue_size   => 'count',
    },
);

has polling_interval => (
    is => 'ro',
    default => 5,
);

has [ qw/ polling_auto_start / ] => (
    is      => 'ro',
    default => 1,
);

has process_interval => (
    is => 'ro',
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
    is => 'ro',
    required => 1,
);

with 'Reflex::Role::Interval' => {
    att_interval      => $_."_interval",
    att_auto_start    => $_."_auto_start",
    att_auto_repeat   => $_."_auto_repeat",
} for qw/ polling process /;


sub on_polling_interval_tick { $_[0]->polling_function->(@_) }
sub on_process_interval_tick { $_[0]->process_function->(@_) }

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

Poller->meta->make_immutable;

1;

package main;

my $foo = Poller->new(
    polling_function => sub { 
        my $self = shift;

        state $i;

        my @new = map { ++$i } 1..rand 5;
        
        $self->log( "polling " . join ', ', @new );
        $self->add_to_queue(@new);
    },
    process_function => sub { 
        my $self = shift;

        my $item = $self->shift_queue or return;

        $self->log( "processing $item" );
    },
);

my $bar = Poller->new(
    polling_interval => 2,  # a little faster
    polling_function => sub { 
        my $self = shift;

        state $i = 'a';

        my @new = map { ++$i } 1..rand 5;
        
        $self->log( "polling " . join ', ', @new );
        $self->add_to_queue(@new);
    },
    process_function => sub { 
        my $self = shift;

        my $item = $self->shift_queue or return;

        $self->log( "processing $item" );
    },
);

Reflex->run_all;

