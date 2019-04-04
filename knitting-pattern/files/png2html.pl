#!/usr/bin/perl 

use 5.10.0;

use GD;
use List::Util qw/ sum /;

my $img = GD::Image->newFromPng(shift) or die;

my ( $width, $height ) = $img->getBounds;

say <<'END';
<html>
<head>
<style>
td { 
    width: 1em; 
    height: 1em;
    padding: 1px;
    border: solid 1px lightgrey; 
}
td.cell-white { background: white }
td.cell-black { background: black }
</style>
</head>
<body> 
<table>
END

say "<table>";

for $y ( 0 .. $height - 1 ) {
    say "<tr>";
    for $x ( 0 .. $width - 1 ) {
        my $color = sum $img->rgb( $img->getPixel( $x, $y ) );

        my $class = 'cell-' . ( $color ? 'white' : 'black' );

        say "<td class='$class'>&nbsp;</td>";
    }
    say "</tr>";
}

say "</table></body></html>";
