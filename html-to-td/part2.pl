style '*' => (
    pre  => \&pre_element,
    post => '};',
);

sub pre_element {
    my ( $self, $node, $args ) = @_;

    my $name = $node->nodeName;

    return "$name {" . pre_attrs( $node );
}

sub pre_attrs {
    my $node = shift;

    my @attr = $node->attributes or return '';

    my $output = 'attr { ';

    for ( @attr ) {
        my $value = $_->value;
        $value =~ s/'/&apos;/g;
        $output .= $_->nodeName . ' => ' . "'$value'" . ', ';
    }

    $output .= '};';

    return $output;
}
