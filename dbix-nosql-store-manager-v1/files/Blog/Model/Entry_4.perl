---
...;
    store_model  => 'Blog::Model::Author',
    is           => 'rw',
);

has associated_tags => (
    traits        => [ 'Array', 'StoreModel' ],
    cascade_model => 1,
    store_model   => 'Blog::Model::Tag',
    is            => 'rw',
    default       => sub { [] },
);

has tags => (
    is      => 'ro',
    default => sub { [ map { $_->tag } $_[0]->associated_tags->@* ] },
    trigger => sub {
        my ( $self, $new ) = @_;
        $self->associated_tags( [ map { +{ entry => $self->store_key, tag => $_ } } @$new ] );
    },
);

__PACKAGE__->meta->make_immutable;
...;
