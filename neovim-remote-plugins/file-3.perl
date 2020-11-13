package Neovim::RPC::Plugin::FileToPackageName;

use 5.20.0;

use strict;
use warnings;

use Neovim::RPC::Plugin;

use Promises qw/ collect /;

use experimental 'signatures';

sub file_to_package_name {
    shift
        =~ s#^(.*/)?lib/##r
        =~ s#^/##r
        =~ s#/#::#rg
        =~ s#\.p[ml]$##r;
}

sub shall_get_filename ($self) {
    $self->api->vim_call_function( fname => 'expand', args => [ '%:p' ] );
}

subscribe file_to_package_name => rpcrequest
    sub($self,@) {
        collect(
            filename => $self->shall_get_filename,
            line     => $self->api->vim_get_current_line,
        )
    },
    sub ($self,$props) {
        $self->api->vim_set_current_line(
            $props->{line} =~ s/__PACKAGE__/
                file_to_package_name($props->{filename})
            /er
        )
    };

