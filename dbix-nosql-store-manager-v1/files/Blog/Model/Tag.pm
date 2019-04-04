package Blog::Model::Tag;

use strict;
use warnings;

use Moose;

with 'DBIx::NoSQL::Store::Manager::Model';

has [qw/ tag /] => (
    traits   => [ 'StoreKey', 'StoreIndex' ],
    is       => 'ro',
    required => 1,
);

has [qw/ entry /] => (
    traits   => [ 'StoreKey', 'StoreIndex', 'StoreModel' ],
    is       => 'ro',
    required => 1,
    store_model => 'Blog::Model::Entry',
);

__PACKAGE__->meta->make_immutable;

1;
