sub process_directives( $self, $doc, @context ) {
    ...;

    $doc->find('.')->and_back->each( sub {
        my $elt = $_;
        my @attrs = map { $_->all_attr } $_->{trees}->@*;
        for my $attr ( @attrs ) {
            next unless $attr =~ s/^://;
            my $v = $elt->attr( ':'.$attr);
            $elt->attr( ':'.$attr => undef );
            $elt->attr( $attr => Template::Mustache::resolve_context( 
                $v,  \@context
            ));
        }
    });

    ...;
}
