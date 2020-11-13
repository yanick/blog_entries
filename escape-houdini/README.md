---
url: escape-houdini
created: 2013-05-14
tags:
    - Perl
    - Escape::Houdini
---

# Escape::Houdini and Related Tales of Prestidigitation

Whoa, for someone who vowed to write a blog entry a week this year, I sure am
getting sporadic.

Buuuut I don't angst too much about it, considering that the lack of movement
above the water's surface belies the frantic paddling going underneath.
Between the [Dancer](cpan) 1 stewardship, writing of toy apps, release of
long-due patches in a slew of modules, helping with the
[PerlWeekly](http://perlweekly.com/) and, y'know, those other pesky Real Life
things, I keep myself quite busy. 

So, you understand that when I saw Mike Doherty's [pitch on PrePAN](http://prepan.org/module/nXWJ8Y9sBme) 
for a Perl module wrapping the goodness of the minimalistic web escaping
library [Houdini](https://github.com/vmg/houdini), I just had to pass.

... and if you believe that, you obviously are new here.

## Throwing Some Bindings Over A Famous Escapist

I was intrigued by the library, roused by the challenge, and while my `XS` skills are worth guano, it
was just enough of a simple project that I had some chances to wing it by
stealing, adapting and sheer animalistic cargo-culting.

So meet [Escape::Houdini](cpan), which sole goal on this world is to
escape (and unescape) web-related stuff (that is, html, xml, url, uri and
javascript).  Compared to the already-existing [HTML::Escape](cpan), 
[URI::Escape](cpan) and their `XS` brethen, this new upstarts brings two
things to the table. For one, it's a one-stop module that provides the
escaping (and unescaping) tools for all of the web thingies at a single,
convenient location. And, most importantly, it lives atop the 
C library produced by the 
[fine GitHub
folks](https://github.com/blog/1475-escape-velocity), which means that 
it's a solid, well-known library that (thank God) is not our problem to 
maintain.

Incidentally, how does `Escape::Houdini` perform when compared with
`HTML::Escape` and [URI::Escape::XS](cpan)? According to very
unscientific benchmarks, it seems to be a tad slower than `HTML::Escape` (but
then, it also escapes a few more characters, so we might have a slight case of
apple/orage smoothie here), but a smidgen faster than `URI::Escape::XS` (where
both 'tad' and 'smidgen' refer to performances within 25% of each others). So,
yeah, nothing to spit at.

## Oh Look, A Segue!

Talking of benchmarks and stuff, I wanted to write this blog entry a few days
ago, but had to poke around with benchmarks beforehand.  This gave me the
occasion to play a little bit with brian d foy's [Surveyor::App](cpan).
It's a very nice system, but I kinda felt it has the weakness that the
whole of the benchmark is contained within a single module. Which got me
thinking...

... and if you are not already groaning and bracing for what's coming, you are
still obviously are quite the yaneophyte.

Aaaanyway, what I thought is that there should be a decoupling of the
benchmarks, which should only describe what is expected of the functions to
benchmark like, say, 

```perl
package Yardstick::Benchmark::WebEscaping;

use strict;
use warnings;

use Moose;

extends 'Yardstick::Benchmark';

benchmark 'basic html escape' => (
    tags   => [qw/ html escape /],
    input  => [ '<body>hello world</body>' ], 
    output => [ '&gt;body&lt;hello world&gt/body&lt;' ]
);

benchmark 'basic html unescape' => (
    tags   => [qw/ html unescape /],
    input  => [ '&gt;body&lt;hello world&gt/body&lt;' ],
    output => [ '<body>hello world</body>' ], 
);

1;
```

and of the different contestants, which provide the functions to be measured:


```perl
package Yardstick::Benchmark::WebEscaping::Houdini;

use strict;
use warnings;

use Escape::Houdini ':all';
use Moose;

extends 'Yardstick::Contender';

has '+info' => (
    default => sub {
        'Escape::Houdini' => Escape::Houdini->VERSION
    },
);

contender 'Escape::Houdini::escape_html()' => (
    tags => [ qw/ html escape / ],
    func => sub { escape_html($_[0]) },
);

contender 'Escape::Houdini::unescape_html()' => (
    tags => [ qw/ html unescape / ],
    func => sub { unescape_html($_[0]) },
);

1;
```

That way, each new contender `Foo` only needs to include a
`Yardstick::Benchmark::XXX::Foo` module in its distribution, and it can be
automatically added to the benchmark. Oh, and noticed the tags? That's just a
ploy to allow for more than one type of behavior by benchmark file; the logic
being that a contender would be run against a benchmark only if 
it has all the tags required by the said benchmark.

By now, I'm ambivalent whether the whole thing is an over-engineered fancy or a
mild stroke of genius. So I guess... I guess I'll have to put it on PrePAN to
find out. Yes, on PrePAN. The very place... where this whole adventure began.

<div align="center">
<iframe width="560" height="315" src="http://www.youtube.com/embed/3RE7uC8QXjY" frameborder="0" allowfullscreen="allowfullscreen"></iframe>
</div>
