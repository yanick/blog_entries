#!/usr/bin/perl 

# see http://use.perl.org/~brian_d_foy/journal/8314

use strict;
use warnings;

use 5.10.0;

use LWP::Simple qw/ get /;
use List::Util qw/ sum /;

my $author = 'YANICK';

$author =~ s#(.)(.)#$1/$1$2/$&#;  # YANICK => Y/YA/YANICK

my $page = get "http://search.cpan.org/CPAN/authors/id/$author";

my %dist;
$dist{$1}++  while $page =~ /<a href="(.*)-v?[\d_.]+\.tar\.gz"/ig;

say "Schwartz factor: ", keys( %dist) / sum values %dist;

while( my ( $dist, $num ) = each %dist ) {
    say $dist, ' - ', $num;
}
