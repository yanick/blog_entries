package Foreman;

use Moose;

use strict;
use warnings;

extends 'Reflex::Base';
with 'MooseX::Loggable';

has new_items => (
    is => 'ro',
    traits => [ 'Array' ],
    handles => {
        add_new_items  => 'push',
        shift_new_item => 'shift',
        nbr_new_items  => 'count',
    },
);



Foreman->new->run_all;



