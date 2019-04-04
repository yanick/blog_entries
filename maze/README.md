---
url: maze
created: 2011-05-15
last_updated: 5 March 2013
tags:
    - Perl
    - Term::Caca
    - Games::Maze
---

# ASCII Interface for Games

> **Update**: The API for `Term::Caca` changed since the original 
> writing of this entry. The code below might not work anymore. 

Although the quantity of tuits I have for them are measured in Planck
time, I still think about games I would like to hack together. One of
them I already [discussed last year][1], and another would be a cross between
[Space Hulk][2], [nethack][3] and the [X-Com series][4].

[1]: http://babyl.dyndns.org/techblog/entry/perl-in-space
[2]: http://en.wikipedia.org/wiki/Space_Hulk 
[3]: http://www.nethack.org/
[4]: http://en.wikipedia.org/wiki/X-COM
[5]: http://www.perltk.org
[6]: http://www.bay12games.com/dwarves/
[7]: http://caca.zoy.org/wiki/libcaca
[8]: http://search.cpan.org/~beppu/
[9]: http://babyl.dyndns.org/techblog/entry/yanick-in-black

Since I have so little time to devote to those pet projects, 
and because I'm no graphical interface ninja (I dabbled with [perl/tk][5],
true, but that was many moons ago), I've looked for ways to ease off 
the burden of the UI.  In the blog entry about the spaceships battle game,
I've mentioned leveraging browsers, SVG and good ol' AJAX, but lately
I thought of another alternative. Why not try an ASCII interface?  Obviously,
it served nethack and its ilk very well, and [Dwarf Fortress][6]
is proof that new insane things can still be done with nothing but colors and 
character sets. Although, to be perfectly honest, DF is a wee bit too hardcore
for me. But then, a long, long time ago, I said the same thing about *vim*,
and look at me now. Anyway...

So, that thought make me look into possible ASCII  modules
on CPAN.  [Term::Caca](cpan), an interface to the regrettably-named but 
quite excellent [libcaca][7], seemed to have a lot of potential, so I tried to
install it and, *oh darn*, found it wasn't compatible with the latest versions
of the library. Nothing that a small patch couldn't solve. Happy about it, I
sent the patch to its maintainer,  [John Beppu][8]. What happened next ties
nicely to my blog entry about the consequences of [contributing to other
peeps's modules][9], and is an excellent example of the harsh, strict,
cold, hard-ball playing, process-oriented ways CPAN authors usually adopt.
To wit, not 24 hours after submitting the patch, 
John and I had an exchange that wasn't too far from:

    John: Thanks for the patch! Hey, I haven't had much time to devote
            to Term::Caca lately, wanna become its prime maintainer?
    Me:   Uh, sure.
    John: There you go. Have fun.

Indeed, there I went. On my journey to get my UIs done in a quick and
dirty way, I ended up the maintainer of yet another module. One more proof
that Fate works in mysterious ways. :-)

As the best way to get a feel for a module is to work with it, I decided 
to try my hand at a small, unassuming maze game. For the maze creation
itself, I used [Games::Maze](cpan), and with that out of the way,
the resulting program turned out to be quite simple:

```perl
#!/usr/bin/perl 

use 5.12.0;

use Games::Maze;
use Term::Caca;
use Term::Caca::Constants qw/ :all /;

my $term = Term::Caca->new;

$term->set_window_title( 'maze' );

my $w = $term->get_width;
my $h = $term->get_height;

# generate the maze
my $maze = Games::Maze->new( 
    dimensions => [ ($w-1)/3, ($h-1)/2 , 1 ], 
    entry => [1,1,1] 
);
$maze->make;
my @maze = map { [ split '' ] }  split "\n", $maze->to_ascii;

# display the maze itself
$term->set_color( CACA_COLOR_LIGHTBLUE, CACA_COLOR_BLACK );
for my $x ( 0..$w ) {
    for my $y ( 0..$h ) {
        $term->putchar( $x, $y, $maze[$y][$x] );
    }
}


$term->set_color( CACA_COLOR_RED, CACA_COLOR_BLACK );

my @pos = (1,0);

while (1) {
    $term->putchar( @pos, '@' );
    $term->refresh;
    $term->putchar( @pos, '.' );

    # move using the keypad (2, 4, 6, 8)
    given ( chr( $term->wait_event( CACA_EVENT_KEY_PRESS ) 
                    ^ CACA_EVENT_KEY_PRESS ) ) {
        when ( 2 ) { 
            if ( $pos[1] < $w and $maze[$pos[1]+1][$pos[0]] eq ' ' ) {
                $pos[1]++;
            }
        }
        when ( 8 ) { 
            if ( $pos[1] > 0 and $maze[$pos[1]-1][$pos[0]] eq ' ' ) {
                $pos[1]--;
            }
        }
        when ( 4 ) { 
            if ( $pos[0] > 0 and $maze[$pos[1]][$pos[0]-1] eq ' ' ) {
                $pos[0]--;
            }
        }
        when ( 6 ) { 
            if ( $pos[0] < $w and $maze[$pos[1]][$pos[0]+1] eq ' ' ) {
                $pos[0]++;
            }
        }
    }
    $term->putchar( @pos, '@' );
}
```

The result is basic (and Games::Maze seems to fail to create a maze from time
to time), but quite playable:

<div align="center"><img src="__ENTRY_DIR__/maze.png" alt="maze screenshot"/></div>
