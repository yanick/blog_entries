style '#document' => (
    content => sub {
        my ( $self, $node, $args ) = @_;
        my $raw = $self->stylesheet->render( $node->childNodes );

        my $output;
        my $err;
        eval { 
            Perl::Tidy::perltidy( 
                source       => \$raw,
                destination  => \$output,
                errorfile    => \$err,
             )
        };

        # send the raw output if Tidy failed
        return $err ? $raw : $output;
    },
);

1;
