package Template::Caribou::DevServer;

use strict;
use warnings;

use Dancer;

use Moose::Role;

sub dev_server {
    my $self = shift;

    hook before => sub { 
        $self->refresh_template_files;

        for my $t ( grep { !$seen{$_} } $self->all_templates ) {
            warn "adding template $t\n";
            get "/$t" => sub { $self->render( $t => %{params()} ) };
            $seen{$t}++;
        }
    };

    my %seen;
    for my $t ( grep { !$seen{$_} } $self->all_templates ) {
        warn "adding template $t\n";
        get "/$t" => sub { $self->render( $t => %{params()} ) };
        $seen{$t}++;
    }


    dance;
}

1;
