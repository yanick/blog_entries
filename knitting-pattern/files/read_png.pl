#!/usr/bin/perl 

use strict;
use warnings;

use 5.10.0;

use GD;
use List::Util qw/ sum /;

my $img = GD::Image->newFromPng('onion.png');

my ( $width, $height ) = $img->getBounds;

for $y ( 0 .. $height - 1 ) {
    for $x ( 0 .. $width - 1 ) {

        # we know it's black or white, so I can be lazy
        my $color = sum $img->rgb( $img->getPixel( $x, $y ) );

        say "cell $x, $y is ", $color ? 'white' : 'black';
    }
}

