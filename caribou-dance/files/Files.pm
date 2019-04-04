package Template::Caribou::Files;

use strict;
use warnings;

use Path::Class;
use Method::Signatures;
use List::Pairwise qw/ mapp /;

use MooseX::SemiAffordanceAccessor;
use Moose::Role;

has template_dirs => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
    trigger => \&load_template_dirs,
);

method load_template_dirs {
    for my $dir ( map { dir($_) }  @{ $self->template_dirs } ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;
             my $f = $_[0]->relative($dir)->stringify;
             $f =~ s/\.bou$//;
             $self->import_template_file( $f => $_[0] );
        });
    }
}

has template_files => (
    traits => [ 'Hash' ],
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
    handles => {
        set_template_file => 'set',
        template_files_mapping => 'elements',
    },
);

sub BUILD { $_[0]->load_template_dirs; }


sub import_template_file {
    my $self = shift;

    my( $name, $file ) = @_ == 2 ? @_ : ( undef, @_ );

    $file = file($file) unless ref $file;

    ( $name = $file->basename ) =~ s/\..*?$// unless $name;

    my $class = ref( $self ) || $self;

    my $sub = eval <<"END_EVAL";
package $class;
use Method::Signatures;
method {
# line 1 "@{[ $file->absolute ]}"
    @{[ $file->slurp ]}
}
END_EVAL

    die $@ if $@;

    $self->set_template( $name => $sub );
    $self->set_template_file( $name => [ $file => $file->stat->mtime ] );

    return $name;
}

method refresh_template_dirs {

    my %seen = mapp { $b->[0] => $b->[1] } $self->template_files_mapping;

    for my $dir ( map { dir($_) }  @{ $self->template_dirs } ) {
        $dir->recurse( callback => sub{ 
             return unless $_[0] =~ /\.bou$/;

             return if $seen{"$_[0]"} >= $_[0]->stat->mtime;

             my $f = $_[0]->relative($dir)->stringify;

             $f =~ s/\.bou$//;
             $self->import_template_file( $f => $_[0] );
        });
    }
}

method refresh_template_files {
    $self->refresh_template_dirs;
}

1;
