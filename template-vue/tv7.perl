sub process_directives( $self, $doc, @context ) {
    ...;

    use experimental 'postderef';

    # TODO have to think about v-fors in v-fors
    $doc->find( '[v-for]' )->each( sub{
        my( $item, $key ) = split /\s+in\s+/, $_->attr('v-for'), 2;
        my @items = Template::Mustache::resolve_context( $key, \@context )->@*;

        my $block = $_;
        $block->attr('v-for' => undef);

        my $new = join '', map {  
            $self->process_directives( 
                $block->clone, 
                { $item => $_ }, 
                @context 
            );
        } @items;

        $block->after($new);
        $block->detach;
        
    });

    ...;
}
