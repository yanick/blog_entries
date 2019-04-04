package Smoke::Module;

use 5.10.0;

use strict;
use warnings;

use Moose;

use MooseX::Types::Path::Class;

use Method::Signatures;
use Path::Class qw/ dir file /;
use File::chdir;
use Archive::Tar;
use TAP::Harness::Archive;
use IPC::Run3;

with 'MooseX::Role::Tempdir' => {
    dirs        => [qw/ tempdir /],
    tmpdir_opts => { CLEANUP => 1 },
};

with 'MooseX::Role::Loggable';

has tarball => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    coerce   => 1,
);

has package_name => ( is => 'rw', );

has package_version => ( is => 'rw', );

has tarball_extracted => (
    isa     => 'Bool',
    default => 0,
    is      => 'rw',
);

has extract_dir => (
    is      => 'ro',
    isa     => 'Path::Class::Dir',
    coerce  => 1,
    lazy    => 1,
    default => method {
        my $dir = dir( $self->tempdir );

        $self->_extract_tarball($dir) unless $self->tarball_extracted;

        return $dir;
    },
);

has perl_exec => (
    is      => 'ro',
    default => $^X,
);

has tap_report => (
    is      => 'rw',
    isa     => 'TAP::Parser::Aggregator',
    lazy    => 1,
    handles => { test_status => 'get_status', },
    builder => 'generate_tap_report',
);

method generate_tap_report {
    my $report = $self->_run_tests;
    $self->tap_reports_generated;
    return $report;
};

sub tap_reports_generated {

    # do nothing, just an action milestone marker
    # for the plugins
}

method _extract_tarball($extract_dir) {
    my $tar = Archive::Tar->new;

    $tar->read( $self->tarball );

    local $CWD = $extract_dir;

    $self->log_debug("extracting tarball to $CWD");

    for my $file ( $tar->list_files ) {
        ( my $dest = $file ) =~ s#^.*?/##;
        $tar->extract_file( $file => $extract_dir->file($dest)->stringify );
    }

    $self->tarball_extracted(1);
}

method extract_tarball {
    $self->_extract_tarball( $self->extract_dir )
        unless $self->tarball_extracted;
}

before _run_tests => method {
    $self->extract_tarball;
};

method _run_tests {
    local $CWD = $self->extract_dir->stringify;

    if ( -f 'Build.PL' ) {
        $self->log_debug("Build.PL detected");

        run3 [ $self->perl_exec, 'Build.PL' ],
          \undef, sub { $self->log_debug(@_) }, sub { $self->log_debug(@_) };
        run3 ['./Build'],
          \undef, sub { $self->log_debug(@_) }, sub { $self->log_debug(@_) };
    }
    elsif ( -f 'Makefile.PL' ) {
        $self->log_debug("Makefile.PL detected");

        run3 [ $self->perl_exec, 'Makefile.PL' ],
          \undef, sub { $self->log_debug(@_) }, sub { $self->log_debug(@_) };
        run3 ['make'],
          \undef, sub { $self->log_debug(@_) }, sub { $self->log_debug(@_) };
    }
    else {
        die "no Build.PL or Makefile.PL found\n";
    }

    run3 [ 'prove', '-b', '--archive', 'tap.tar.gz', 't' ];

    # TODO we could also scoop the meta.yml from the results
    return TAP::Harness::Archive->aggregator_from_archive(
        { archive => $self->extract_dir->file('tap.tar.gz') } );
}

method run_tests {
    $self->tap_report( $self->_run_tests );
    $self->tap_reports_generated;

    return $self->test_status;
}

1;
