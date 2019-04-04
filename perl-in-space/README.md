---
title: Perl in Spaaace!
url: perl-in-space
format: markdown
created: 2010-12-30
tags:
    - Perl
    - game
    - Raphaël
    - SVG
    - JavaScript
    - Dancer
    - jQuery
---

I like turn-based strategy games. They tend to agree with my... aah, 
sometimes less than real-time thinking process. I love even more
full-fledged campaign turn-based strategy games, where I can let my
megalomania run rampant. Games like the 
[X-Com series](http://en.wikipedia.org/wiki/X-COM),
[Battle for Wesnoth](http://www.wesnoth.org/) and 
[MegaMek/MekWars](http://sourceforge.net/projects/megamek/).

Now, let's be honest: playing the game is fun, but writing the game is even more
of a blast. So I've been toying with the idea of implementing one
such a game for a long time, and for its interface been pondering about using a SVG-based web
application, as this nicely solves cross-platform compatibilities. 
But in the past browsers' support of SVG, and mostly SVG animations,
was a big disappointment, so I waited. Now, though, it seems that browsers are
almost there, and with the little help of JavaScript libraries like
[Raphaël](http://raphaeljs.com/), should be in a usable state.  

In all cases, since I'm vacation and have time to devote to new tech
exploration, I've decided to go ahead and prototype around, just to see how
far a few days could lead me.

For the game itself, I've decided to aim for a space battle tactical game.
Mostly because it's probably the easiest environment to pitch battles in:
backdrop is black, sprinkled with stars, and there no hindrace of line of
sight or anything of the sort. 
As inspiration for the game mechanics, I'm looking
at the table-top game [Full Thrust](http://www.groundzerogames.net/index.php?option=com_content&task=view&id=31&Itemid=50) and its play-by-email adaptation 
[ftjava](http://home.roadrunner.com/~davisje/ftjava/index.html). 

## First thing: let there be display!

Of course, there would not be much of a game if we couldn't 
show a map with all the ships on it. So let's begin with that.

As mentioned above, I've decided to use SVG for the graphical displays and,
for now, `Raphaël` as its API. Using it, let's get ourselves a simple,
star-studded map:

<galuga_code code="xml">index.html</galuga_code>

We can't see because there's nothing on the map, but thanks 
to [Raphael-ZPD](https://github.com/somnidea/raphael-zpd) we
can zoom and pan in our new viewport with the mouse without having to add a
line of code. This is very nice.

<div align="center"><img src="__ENTRY_DIR__/screen1.png" /></div>

## Space shouldn't be that empty: adding a ship

Now the fun stuff truly begin. We want to add ships (well, to start off, a
single ship), and we want to add then dynamically. 

To do that, we'll need a web application to feed data to the webpage. 
So I quickly create a Dancer application.  `/radar` is its first action, which
will return a JSON representation of what should be on the map:

<galuga_code code="Perl">radar.pl</galuga_code>

From the webpage side, we'll now summon the power of `jQuery` to
slurp the information from the web app and display the ship when
the page load:

<galuga_code code="xml">load_ship.html</galuga_code>

If we try it, we get:

<div align="center"><img src="__ENTRY_DIR__/screen2.png" /></div>

The ship is a little big, but we can zoom out with the scroll-wheel and
see that we can also drag the mouse and pan around. Yay!

## To boldly go... that way!

Next on the list, I want to give a course to the ship, and I want the
resulting trajectory to be outlined on the screen. 

For the command itself, I'll use the `Full Thrust` system, which is
text-based. I'll not go into details here; suffice to say that
the commands will look like `2P-2` (which, in this case, means "turn 60
degrees port (2 times 30 degrees) and decrease velocity of 2 units).

On the web application side, I add the action `/plot_course`, which takes
that command, computes if it makes senses and spits back any comments from
the ship's pilot along the plotted trajectory:

<galuga_code code="Perl">plot_course.pl</galuga_code>

We can see a pattern here. The application's controller is as dumb as
possible, and let the `Ship` model take care of all the logistic.

On the webpage, we add the input field, and the required ajax magic:

<galuga_code code="xml">plot_course.html</galuga_code>

We reload the application and... the ship can now plot its course. The funny
semi-arc, by the by, is expected and is the way the `Full Thrust` system 
work. Trust me. :-)

<div align="center"><img src="__ENTRY_DIR__/screen3.png" /></div>

## "Ensign... engage!"

Our course is plotted. By now, I'm all eager to fire up the ship's
main reactors.  Of course, I could go the easy route and just show 
the ship at its new location for the next round, but to see it move
around would be much cooler.  Well, `Raphaël` supports animation, so 
let's try it.

On the server side, we're adding the action `/move`, which pretty much
does the same thing as `/set_course`, but also acts on it:

<galuga_code code="Perl">move.pl</galuga_code>

For the webpage-side, we'll use the trajectory we already have as the 
animation path. Except for the 3 lines(!) pertaining to the animation, 
the resulting code is almost identical to the one to set the course, 
hinting that we could refactor the logic to something much more concise.

<galuga_code code="xml">move.html</galuga_code>

And now if we click "make it so", we... well, *I* can see the ship move.
If you want to see it move too, the code is on
[GitHub](http://github.com/yanick/shipgame).
The animation is a little jerky, but that might be due to the less
than muscular state of my computer. And while that jerkiness doesn't bode
quite well 
for the animation of a full armada, it's still a not-so-bad first step. 

## Lessons learned

* SVG animation in the browser is getting better. It's maybe not quite there
yet, but at least there's hope.

* Not only `Raphaël` and its plugins make SVG manipulations easier, but 
I've discovered that jQuery and FireBug are also quite happy to do their stuff
with SVG as well as HTML.  That's two additional mighty tools I was not
expecting to have at my disposal.

* Caveat to the bullet above. `Raphaël` and cohorts make SVG stuff easier, but
it's not yet a walk in the park.  There are things like manual zooming and
grouping of elements that still require a lot of tuning and homebrew code.

* For quick prototyping, Dancer is quite the bee's knee. 
