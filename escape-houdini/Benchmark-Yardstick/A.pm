package A {

use strict;
use warnings;

use Moose;
use MooseX::ClassAttribute;

class_has foo => (
    is => 'ro',
    isa => 'ArrayRef',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        add => 'push',
        all => 'elements',
    },
);

}

1;
