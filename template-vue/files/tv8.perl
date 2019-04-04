use Module::Runtime qw/ use_module /;

sub process_directives( $self, $doc, @context ) {
    ...;

    for my $component ( $self->components->@* ) {
        my $name = lc $component =~ s/.*:://r;
        $doc->find($name)->each(sub{
            my $elt = $_;

            my %attr = map { $_ => $elt->attr($_) } 
                            $_->{trees}[0]->all_attr;

            $elt->after(
                use_module($component)->new( %attr )->render
            );
            $elt->detach;
        });
    }

    ...;
}
