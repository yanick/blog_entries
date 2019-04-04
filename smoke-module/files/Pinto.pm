package Smoke::Module::Pinto;

use 5.10.0;

use strict;
use warnings;

use Moose::Role;

use MooseX::Role::AttributeOverride;

use Method::Signatures;
use Pinto::Schema;
use version;

has_plus 'tarball' => (
    required => 0,
    lazy => 1,
    default => \&_pinto_tarball,
);

has pinto_root => (
    is => 'ro',
    lazy => 1,
    default => sub { 
        $ENV{PINTO_REPOSITORY_ROOT} or 
        die "Module::Pinto::new() requires argument 'pinto_root'\n" 
    },
);

method _pinto_tarball {
    my $schema = Pinto::Schema->connect(
        'dbi:SQLite:' . $self->pinto_root . '/.pinto/db/pinto.db' );

    die "either argument 'package_name' or 'tarball' has to be given\n"
        unless $self->package_name;

    my $rs = $schema->resultset('Package')->search({
        name => $self->package_name,
    });

    # has version ? => find that one
    # has not? take the highest version
    my $package;
    if ( $self->package_version ) {
        $rs = $rs->search({ version => $self->package_version });
        $package = $rs->first;
    }
    else {
        ( $package ) = reverse sort { 
            version->parse($a->version) <=> version->parse($b->version) 
        } $rs->all;

        $self->package_version( $package->version );
    }

    return $self->pinto_root . '/' .$package->distribution->native_path;
}

1;
