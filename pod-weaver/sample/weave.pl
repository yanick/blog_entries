
    use strict;
    use warnings;

    use Pod::Weaver;
    use File::Slurp;
    use PPI::Document;

    my $filename = shift @ARGV;

    # create Pod::Weaver engine, taking 'weaver.ini' config
    # into account
    my $weaver = Pod::Weaver->new_from_config;

    my $perl = File::Slurp::read_file( $filename );

    # get PPI DOM of the file to process
    my $ppi  = PPI::Document->new( \$perl );

    # get its POD as an Pod::Elemental DOM object
    my $pod = Pod::Elemental->read_string(
        join '', @{ $ppi->find( 'PPI::Token::Pod' ) || [] }
    );

    # ...and remove it from the PPI
    $ppi->prune( 'PPI::Token::Pod' );

    # weaver, do your stuff
    my $doc = $weaver->weave_document({
        pod_document => $pod,
        ppi_document => $ppi,
    });

    # print the generated POD
    print $doc->as_pod_string;

