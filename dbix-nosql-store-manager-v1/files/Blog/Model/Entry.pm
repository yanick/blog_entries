---
package Blog::Model::Entry;

use Scalar::Util qw/ blessed /;

use strict;
use warnings;

use Moose;

with 'DBIx::NoSQL::Store::Manager::Model';

use experimental 'postderef';

has url => (
    traits   => [ 'StoreKey' ],
    is       => 'ro',
    required => 1,
);

has author => (
    traits => [ 'StoreModel' ],
    cascade_save => 1,
    store_model => 'Blog::Model::Author',
    is     => 'rw',
);

has associated_tags => (
    traits => [ 'Array', 'StoreModel' ],
    cascade_model => 1,
    store_model => 'Blog::Model::Tag',
    is     => 'rw',
    default => sub { [] },
);

has tags => (
    is => 'ro',
    default => sub { [ map { $_->tag } $_[0]->associated_tags->@* ] },
    trigger => sub {
        my ( $self, $new ) = @_;
        $self->associated_tags( [ map { +{ entry => $self->store_key, tag => $_ } } @$new ] );
    },
);

has content => (
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;

1;
