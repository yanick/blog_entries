package Pulp::Action::Less;

use 5.10.0;

use strict;
use warnings;

use Moose;
use CSS::LESS;
use PerlX::Maybe;

with 'Pulp::Role::Action::Editor';

has "include_paths" => (
    is => 'ro',
);

has "engine" => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return CSS::LESS->new(
            maybe include_paths => $self->include_paths
        );
    },
);

sub edit {
    my( $self, $folio ) = @_;

    $folio->content( join '', $self->engine->compile( $folio->content ) );
    $folio->filename( $folio->filename =~ s/\.less/\.css/r );

    return $folio;
}

1;
