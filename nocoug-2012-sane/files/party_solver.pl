package PartyResolver;

use 5.10.0;

use strict;
use warnings;

use Moose;
use Method::Signatures;

use Set::Object;
use Algorithm::Combinatorics qw/ subsets /;
use List::MoreUtils qw/ uniq first_index /;
use List::Util qw/ min /;

has dependencies => (
    traits   => [qw/ Array /],
    is       => 'ro',
    required => 1,
    isa      => 'ArrayRef[Str|ArrayRef]',
    handles  => { all_deps => 'elements', },
);

sub flatten ($) { ref $_[0] ? @{$_[0]} : $_[0] }

has guests => (
    is      => 'ro',
    lazy    => 1,
    isa     => 'Set::Object',
    default => method {
        return Set::Object->new( map { flatten $_ } $self->all_deps );
    },
    handles => {
        'nbr_guests' => 'size',
        'all_guests' => 'members',
    },
);


method seeders_to_invite {
    for my $group_size ( 1 .. $self->nbr_guests ) {
        my @solutions =
          grep { $self->makes_full_house($_) }
          map  { Set::Object->new(@$_) }
          subsets( [ $self->all_guests ], $group_size );

        return @solutions if @solutions;
    }
}

method makes_full_house($group) {
    # we want a copy, not the original
    $group = Set::Object->new( $group->members );

    my $last_size = 0;
    my @deps      = $self->all_deps;

    while (1) {
        # everybody's in, success!
        return 1 if $group->size == $self->nbr_guests;

        for ( 0 .. $#deps / 2 ) {
            my @who  = flatten $deps[ 2 * $_ ];
            my @deps = flatten $deps[ 2 * $_ + 1];

            $group->insert(@who) if $group->contains(@deps);
        }

        # the group has reached its stable state
        return 0 if $last_size == $group->size;

        $last_size = $group->size;
    }
}

__PACKAGE__->meta->make_immutable;
1;

package main;

my @datasets = ( [
        [qw/ Burdock Carlotta/]      => 'Albus',
        [qw/Albus Daisy/]            => 'Carlotta',
        [qw/Albus Burdock Carlotta/] => 'Elfrida',
        [qw/Carlotta Daisy/]         => 'Falco',
        [qw/Burdock Elfrida Falco/]  => [qw/ Carlotta Daisy/],
        'Daisy'                      => [qw/ Albus Burdock /],
    ],
    [   'Carlotta' => [qw/ Albus Burdock /],
        Falco      => [qw/ Daisy Elfrida /],
    ],
    [   'Carlotta'            => [qw/ Albus Burdock /],
        Falco                 => [qw/ Daisy Elfrida /],
        [qw/ Carlotta Falco/] => [qw/ Albus Burdock Daisy Elfrida /],
    ],
    [   Burdock  => 'Albus',
        Carlotta => 'Burdock',
        Carlotta => 'Albus',
        Elfrida  => 'Daisy',
        Falco    => 'Elfrida',
        Falco    => 'Daisy',
    ],
    [   Burdock                => 'Albus',
        Carlotta               => 'Burdock',
        Carlotta               => 'Albus',
        Elfrida                => 'Carlotta',
        Falco                  => 'Elfrida',
        Falco                  => 'Daisy',
        [qw/ Carlotta Falco /] => [qw/ Albus Burdock Daisy Elfrida /],
    ],
    [   Burdock  => 'Albus',
        Carlotta => 'Burdock',
        Carlotta => 'Albus',
        Elfrida  => 'Daisy',
        Falco    => 'Elfrida',
        Falco    => 'Daisy',
        Carlotta => 'Burdock',
        Albus    => 'Carlotta',
        Albus    => 'Burdock',
        Falco    => 'Elfrida',
        Daisy    => 'Falco',
        Daisy    => 'Elfrida',
    ],
    [   Albus => [qw/ Burdock Carlotta Daisy /],
        Albus => [qw/ Carlotta Daisy Elfrida /],
        Albus => [qw/ Daisy Elfrida Falco /],
    ],
    [   [qw/ Burdock Carlotta Daisy Elfrida Falco /] => 'Albus',
        Albus => [qw/ Burdock Carlotta Daisy Elfrida Falco /],
    ],
);

for (@datasets) {
    state $dataset_nbr = 1;

    say "\nProblem ", $dataset_nbr++;

    say join " ", sort $_->members
      for PartyResolver->new( dependencies => $_ )->seeders_to_invite;

    say '*' x 60;
}
