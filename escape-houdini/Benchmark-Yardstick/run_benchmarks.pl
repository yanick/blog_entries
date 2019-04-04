#!/usr/bin/perl 

use strict;
use warnings;

use Benchmark::Yardstick::WebEscaping;

my $bench = Benchmark::Yardstick::WebEscaping->new;

$bench->print_report;


