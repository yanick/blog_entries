package Catalyst::Controller::VersionedURI;

use strict;
use warnings;

use Moose;

BEGIN { extends 'Catalyst::Controller' }

# I'm going to hell for that one...
( my $app = __PACKAGE__ ) =~ s/::.*//;  

my @uris = ref( $app->config->{VersionedURI}{uri} ) 
         ? @{  $app->config->{VersionedURI}{uri} }
         : $app->config->{VersionedURI}{uri}
         ;

s#^/## for @uris;

my $regex = join '|', @uris;

# we catch the old versions too
eval <<"END";
sub versioned :Regex('(${regex})v') {
    my ( \$self, \$c ) = \@_;

    my \$uri = \$c->req->uri;

    \$uri =~ s#(${regex})v.*?/#\$1#;

    \$c->res->redirect( \$uri );

}
END

1;
