---
title:          Easy Knitting Pattern Generation
url:            knitting-pattern
format:         markdown
created:         9 Aug 2010
original: the Pythian blog - http://www.pythian.com/news/15485/easy-knitting-pattern-generation/
tags:
    - Perl
    - knitting
    - GD
    - SVG
    - gimp
    - HTML
---

<div style="float: right">
<img src="__ENTRY_DIR__/vignette.png" alt="Onion pattern" />
</div>

*This blog entry is based on true events. Only the pattern has been
modified to protected the innocent.*

A few days ago, I was quietly minding my own business when I noticed something 
from the corner of my eyes.  Strangely, the Knitting Goddess who happens to
share my abode did not have the usual mad whirlwind
of knitting needles and yarn in her lap. Instead, she was hunched over a pad
of paper, a serious crease between her eyebrows, and the
pink tip of a tongue sticking out between lips taut with concentration. Curiosity 
got the better of me. I pushed my chest out and strutted in her direction. Once 
by her side, I nonchalently rested my elbow on my knee, 
and asked with a low, husky voice: "Whatchadoing?".

The gentle lady looked up at me in surprise, and coyly admitted that she 
was working on designing a ruana pattern.  Engrossing work without a doubt, but
-- and that she confessed with a demure blush -- quite onerous and time consuming.

That got me thinking. Absentmindely scratching the stubbles on my chin, I
pensively peered into the distance.
Those patterns -- I mused aloud -- they're nothing but grids, right?
A variation on regular digital images. Surely, yes surely, some judicious hacking could help ease
this most delectable damsel in distress? 

Hearing this, the lovely lass's eyes widened and, clasping her hands to her
bosom, she exclaimed that such help would rock most wickedly indeed. Incensed by 
her enthousiasm, I promptly decided to take up the challenge. Thus an alliance was
forged between the queen of crafts and myself, joining 
our
thinking caps to 
come up with a better way to create new knitting patterns.

As a first step, we chose the image that would serve as the base for the
pattern. For the good of the retelling of this tale, let's say it was 

<img src="__ENTRY_DIR__/original.png" alt="original picture"/>

I asked the delightful artist to open that image in her favorite image editor 
and to scale it such that one pixel would correspond to one
square of the pattern. Also, the number of colors had to be reduced 
to the one wanted for the pattern -- in our case, that was a very easy 
black. That doctoring done, the result was saved in a `png` format.

<img src="__ENTRY_DIR__/pixelized.png" alt="pixelized"/>

Thus far, my pretty partner in crime had been manning the keyboard.
With a dramatic flourish of the arms, I announced that here was were
I entered the picture. The `png` image file technically had all the information required
for the pattern. Now all I had to do was to take that information and
massage it into a prettier format.  First things first, thought. How to extract the
data?  I opted for [GD](cpan).

```perl
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

```


So far, so good.  Now, which format should be used for the final pattern?
Initially, I thought of being cute and to generate HTML:

```perl
#!/usr/bin/perl 

use 5.10.0;

use GD;
use List::Util qw/ sum /;

my $img = GD::Image->newFromPng(shift) or die;

my ( $width, $height ) = $img->getBounds;

say <lt;<lt;'END';
<lt;html>
<lt;head>
<lt;style>
td { 
    width: 1em; 
    height: 1em;
    padding: 1px;
    border: solid 1px lightgrey; 
}
td.cell-white { background: white }
td.cell-black { background: black }
<lt;/style>
<lt;/head>
<lt;body> 
<lt;table>
END

say "<lt;table>";

for $y ( 0 .. $height - 1 ) {
    say "<lt;tr>";
    for $x ( 0 .. $width - 1 ) {
        my $color = sum $img->rgb( $img->getPixel( $x, $y ) );

        my $class = 'cell-' . ( $color ? 'white' : 'black' );

        say "<lt;td class='$class'>&nbsp;<lt;/td>";
    }
    say "<lt;/tr>";
}

say "<lt;/table><lt;/body><lt;/html>";
```


The resulting [html output](__ENTRY_DIR__/onion.html) 
worked, but didn't scale too well for big patterns. Browsers,
for some reason, didn't take too well to tables with tens of thousands
of cells. The wussies. 

Oh well. SVG might do the trick, then?


```perl
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

```

That gave a [much better result](__ENTRY_DIR__/onion.svg), but the larger patterns were still 
somewhat of a
challenge for the renderer. So, at last, I opted for the most reasonable 
option: a plain old image. The pattern had been born as a `png`, and 
it seemed destined to stay a `png`. Albeit a cuter one.

```perl
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

```

That, finally, hit the spot just right:

<div align="center">
<a href="__ENTRY_DIR__/pattern.png"><img src="__ENTRY_DIR__/final.png" /></a>
<br />
Click on the image to see the pattern in its full-size glory.
</div>

That pattern  was received with squeals of glee, and I was lavished with many
a reward. Among those rewards were five balls of most the delightful yarn, one of
which was the perfect hue of green for that little Cthulu amigurumi project I
have... Hum. Yeah... Take that as a warning, fellow hackers. For knitting creatures are
of a crafty and corrupting sort. Never, and I mean *never* let them show you how to
crochet. Chances are, you'll get hooked on the spot.


