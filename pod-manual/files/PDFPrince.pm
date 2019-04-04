package Pod::Manual::Formatter::PDFPrince;

use Moose::Role;

use Carp;
use File::ShareDir qw/ dist_file /;

sub save_as_pdf {
    my ( $self, %arg ) = @_;

    my $docbook = $self->as_docbook( 
        css => dist_file( 'Pod-Manual', 'prince.css' )
    );

    open my $db_fh, '>', 'manual.docbook'
        or croak "can't open file 'manual.docbook' for writing: $!";

    print $db_fh $docbook;
    close $db_fh;

    system 'prince', 'manual.docbook', '-o', $arg{filename};
}

1;
