package Benchmark::Yardstick::WebEscaping;

use strict;
use warnings;

use Moose;
use Benchmark::Yardstick;

extends 'Benchmark::Yardstick';

benchmark name => 'basic html escape',
    tags => [qw/ html escape /],
    input => [ '<body>hello world</body>' ], 
    output => [ '' ];

1;


