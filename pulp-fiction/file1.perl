package PoC;

use 5.20.0;

use strict;
use warnings;

use Pulp;
use MooseX::Types::Path::Tiny qw/Path/;

use Pulp::Actions qw/ Src Rename Dest Less WebQuery Concat /;

use experimental 'signatures';

has dest_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => sub {
        Path::Tiny->tempdir;
    },
);

has src_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => 't/corpus/poc',
);

has css_file => (
    isa     => 'Str',
    is      => 'ro',
    default => 'style.css',
);

proof default => sub ($pulp) {
    my $src = quotemeta $pulp->src_dir;
    my $css = $pulp->css_file;

    pulp_src( $pulp->src_dir . '/*' )
    => pulp_rename( sub { s#^$src/## } )
    => {
       qr/\.less$/ => sub{
          pulp_less() => pulp_concat($pulp->css_file)
       },
       qr/\.html$/ => pulp_webquery( sub {
            $_->find('head')->append(
                "&lt;link href='$css' rel='stylesheet' type='text/css'>"
            )
        }),
    }
    => pulp_dest( $pulp->dest_dir );
};

1;
