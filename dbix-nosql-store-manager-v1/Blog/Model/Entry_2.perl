---
...;
with 'DBIx::NoSQL::Store::Manager::Model';

has url => (
    traits   => [ 'StoreKey' ],
    is       => 'ro',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
...;
