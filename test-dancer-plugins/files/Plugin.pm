package DancerTest::Model::Plugin;

use 5.10.0;

use strict;
use warnings;

use Method::Signatures;
use IPC::Cmd 'run';

use DancerTest;
use DancerTest::Types qw/ DateTimeClass /;

use Moose;
 
with 'DBIx::NoSQL::Store::Model::Role';

has '+store_key' => (
    default => method {
        join ' : ', $self->name, $self->timestamp;
    },
);
 
has name => (
    traits => [ 'StoreIndex' ],
    isa    => 'Str',
    is     => 'ro',
    required => 1,
);
 
has timestamp => (
    traits  => [ 'StoreIndex' ],
    isa     => 'DateTimeClass',
    is      => 'ro',
    lazy    => 1,
    default => sub { DateTime->now },
);

has version => (
    traits => [ 'StoreIndex' ],
    isa    => 'Str',
    is     => 'ro',
    lazy    => 1,
    default => method { 
        my $version;
        run( command => "pinto install --info " . $self->name, buffer => \$version );

        chomp $version;
        $version =~ s/^.*-//;
        $version =~ s/\.tar.gz$//;

        return $version;
    },
);

has dancer1_pass => (
    traits => [ 'StoreIndex' ],
    isa    => 'Bool',
    is     => 'ro',
    lazy    => 1,
    default => method { 
        $self->run_tests;
    },
);

has dancer2_pass => (
    traits => [ 'StoreIndex' ],
    isa    => 'Bool',
    is     => 'ro',
    lazy    => 1,
    default => method { 
        local $ENV{PERL5LIB} = '/home/yanick/work/perl-modules/Dancer2/lib';
        $self->run_tests;
    },
);

method run_tests {
    return scalar( run( command => "pinto install --test-only " . $self->name
    ) ) ? 1 : 0;
}

has verbose => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
);

before 'store' => method {
    say "testing ", $self->name;
};

after 'store' => method {
    use Data::Printer;
    p $self->pack;
};
 
__PACKAGE__->meta->make_immutable;
 
1;
