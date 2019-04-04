package Benchmark::Yardstick::WebEscaping::Houdini;

use strict;
use warnings;

use Moose;

extends 'Benchmark::Yardstick::Contender';

has '+info' => (
    default => sub {
    },
);

contender 
    name => 'Escape::Houdini::escape_html()',
    tags => [ qw/ html escape / ],
    func => sub {
    },
    ;
        


1;
