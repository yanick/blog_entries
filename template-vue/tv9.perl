sub render($self) {
    my $mustached = $self->render_mustache;

    my $directived = $self->process_directives( $mustached );

    return $directived;
}
