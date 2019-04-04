package Catalyst::Plugin::VersionedURI;

use 5.10.0;

use strict;
use warnings;

use Moose::Role;

sub _uris {
    my $self = shift;

    state @uris;

    unless ( @uris ) {
        my $conf = $self->config->{VersionedURI}{uri};
        @uris = ref($conf) ? @$conf : ( $conf );

        s#^/## for @uris;
    }

    return @uris
}

around uri_for => sub {
    my ( $code, $self, @args ) = @_;

    my $uri = $self->$code(@args);

    my $base = $self->req->base;
    $base =~ s#(?<!/)$#/#;  # add trailing '/'

    state $uri_re = join '|', $self->_uris;

    state $version = $self->VERSION;

    $$uri =~ s#(^\Q$base\E$uri_re)#${1}v$version/#;

    return $uri;
};

1;
