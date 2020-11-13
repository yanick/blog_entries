---
...;
        $self->associated_tags( [ map { +{ entry => $self->store_key, tag => $_ } } @$new ] );
    },
);

has content => (
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
...;
