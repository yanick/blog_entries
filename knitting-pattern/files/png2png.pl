#!usr/bin/perl 

use strict;
use warnings;

use GD;

my $filename = shift;

my $img = GD::Image->newFromPng($filename) or die;

$filename =~ s/(\.png)/_pattern$1/;

my ( $nbr_cols, $nbr_rows ) = $img->getBounds;

my $sq_unit     = 16;
my $sq_margin   = 3;
my $page_margin = 40;

my $width  = 2 * $page_margin + $sq_unit * $nbr_cols;
my $height = 2 * $page_margin + $sq_unit * $nbr_rows;

my $pattern = GD::Image->new( $width, $height );

# a few colors we'll need
my $grey     = $pattern->colorAllocate( (200) x 3 );
my $darkgrey = $pattern->colorAllocate( (100) x 3 );
my $white = $pattern->colorAllocate( 255, 255, 255 );
my $black = $pattern->colorAllocate( 123, 0,   0 );

# the canvas
$pattern->filledRectangle( 0, 0, $width, $height, $white );

for my $r ( 0 .. $nbr_rows ) {
    my $y = $r * $sq_unit + $page_margin;
    $pattern->line( $page_margin, $y, $width - $page_margin,
        $y, ( $nbr_rows - $r ) % 5 ? $grey : $darkgrey );
}

for my $c ( 0 .. $nbr_cols ) {
    my $x = $c * $sq_unit + $page_margin;
        # we want darker 5x5 squares
    $pattern->line(
        $x, $page_margin, $x,
        $height - $page_margin,
        ( $nbr_cols - $c ) % 5 ? $grey : $darkgrey
    );
}

my %rgbs;
for my $y ( 0 .. $nbr_rows - 1 ) {
    for my $x ( 0 .. $nbr_cols - 1 ) {

        my $rgb = join ":", $img->rgb( $img->getPixel( $x, $y ) );

        $pattern->filledRectangle(
            $page_margin + $sq_unit * $x + $sq_margin,
            $page_margin + $sq_unit * $y + $sq_margin,
            ( $page_margin + ($sq_unit) * ( 1 + $x ) - $sq_margin ),
            ( $page_margin + ($sq_unit) * ( 1 + $y ) - $sq_margin ),
            $rgbs{$rgb} ||= $pattern->colorAllocate( split ':', $rgb ),
        );
    }
}

$pattern->useFontConfig(1);

# number our rows and columns

for my $i ( 1 .. ( $nbr_cols / 5 ) ) {
    $pattern->stringFT(
        $black,
        '/var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/Courier_New.ttf',
        10,
        0,
        $width - $page_margin - 5 * $i * $sq_unit - $sq_unit / 2,
        ,
        $height - $page_margin + 15,
        5 * $i
    );
}

for my $i ( 1 .. ( $nbr_rows / 5 ) ) {
    $pattern->stringFT(
        $black,
        '/var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/Courier_New.ttf',
        10,
        0,
        $width - $page_margin + 5,
        $height - $page_margin - 5 * $i * $sq_unit,
        5 * $i
    );
}

open my $fh, '>', $filename;
print $fh $pattern->png;

