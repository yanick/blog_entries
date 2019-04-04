---
...;
has url => (
    traits   => [ 'StoreKey' ],
    is       => 'ro',
    required => 1,
);

has author => (
    traits       => [ 'StoreModel' ],
    cascade_save => 1,
    store_model  => 'Blog::Model::Author',
    is           => 'rw',
);

__PACKAGE__->meta->make_immutable;
...;
