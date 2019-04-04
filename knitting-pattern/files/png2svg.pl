#!usr/bin/perl 

use strict;
use warnings;

use SVG;
use GD;
use List::Util qw/ sum /;

my $img = GD::Image->newFromPng(shift) or die;

my ( $nbr_cols, $nbr_rows ) = $img->getBounds;

my $sq_unit = 16;

my $width  = $sq_unit * $nbr_cols;
my $height = $sq_unit * $nbr_rows;

my $svg = SVG->new( width => $width, height => $height );

for my $r ( 0 .. $nbr_rows ) {
    $svg->line(
        x1    => 0,
        x2    => $width,
        y1    => $r * $sq_unit,
        y2    => $r * $sq_unit,
        style => { stroke => 'rgb(10,10,10)', } );
}

for my $c ( 0 .. $nbr_cols ) {
    my $x = $c * $sq_unit;
    $svg->line(
        y1    => 0,
        y2    => $height,
        x1    => $x,
        x2    => $x,
        style => { stroke => 'rgb(10,10,10)', } );
}

for my $y ( 0 .. $nbr_rows - 1 ) {
    for my $x ( 0 .. $nbr_cols - 1 ) {

        next if ( sum $img->rgb( $img->getPixel( $x, $y ) ) ) == 255 * 3;
        my $color =
          "rgb(" . ( join ',', $img->rgb( $img->getPixel( $x, $y ) ) ) . ')';

        $svg->rect(
            x      => $sq_unit * $x + 3,
            y      => $sq_unit * $y + 3,
            width  => $sq_unit - 6,
            height => $sq_unit - 6,
            style  => { fill => $color, } );
    }
}

print $svg->xmlify;

