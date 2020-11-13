package Smoke::Module::Store;

use 5.10.0;

use strict;
use warnings;

use Moose::Role;

use MooseX::Storage::Engine;
use DBIx::NoSQL::Store::Manager;
use Method::Signatures;
use MooseX::Role::AttributeOverride;
use MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize;

with 'DBIx::NoSQL::Store::Manager::Model';

has store_db => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $store = DBIx::NoSQL::Store::Manager->new(
            model => 'Smoke::Module',
        );

        MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize->meta->apply(
            $_[0]->meta->find_attribute_by_name($_)
        ) for qw/ 
            debug
            logger 
            logger_facility
            logger_ident
            log_to_file
            log_to_stdout
            log_file
            log_path
            log_pid
            log_fail_fatal
            log_muted
            log_quiet_fatal
        /;   

        $store->json->allow_blessed(1);

        $store->connect( 'test.sqlite' );

        return $store;
    }
);

has_plus 'store_key' => (
   default => method {
    join " : ", $self->package_name, $self->package_version, scalar localtime;
   }
);

after tap_reports_generated  => sub { $_[0]->store };

MooseX::Storage::Engine->add_custom_type_handler(
    'Path::Class::Dir' => (
        expand   => sub { dir(shift) },
        collapse => sub { ''.shift },
    ),
);

MooseX::Storage::Engine->add_custom_type_handler(
    'Path::Class::File' => (
        expand   => sub { file(shift) },
        collapse => sub { ''.shift },
    )
);

MooseX::Storage::Engine->add_custom_type_handler(
    $_ => (
        expand   => sub { bless shift, $_ },
        collapse => sub { return { %{$_[0]} } },
    )
) for qw/
    TAP::Parser::Aggregator
    TAP::Parser
    File::Temp::Dir
/;

1;

