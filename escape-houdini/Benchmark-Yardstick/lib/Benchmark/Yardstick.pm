package Benchmark::Yardstick;

use strict;
use warnings;

use Moose;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    as_is => [ 'benchmark' ],
);

sub benchmark {
    my $caller = caller;

    my $bench = Benchmark::Yardstick::Benchmark->new(@_);
    $caller->add_benchmark($bench);
}

sub run_all_benchmarks {
    my $self = shift;

    $self->run_benchmark( $_ ) for $self->all_benchmark_names;
}

sub run_benchmark {
    my( $self, $name ) = @_;

    my %result;

    my @contenders = $self->contenders_for_benchmark( $name );
    my $benchmark = $self->benchmark($name);

    my @input = $benchmark->input;
    my @output = $benchmark->output;

    for my $c ( @contenders ) {
        my $sub = $c->func;
        my $t = countit( 10, sub { my @x = $sub->(@input) } );
        $self->add_result( $c->name => {
            iterations => $t->iters,
            time => timestr($t),
        });
    }

}


1;

