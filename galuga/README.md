---
created: 2010-09-23
tags:
    - Perl
    - Galuga
    - blog engine
    - Angerwhale
    - Movable Type
    - use.perl.org
    - Wordpress
    - Rubric
    - blosxom
    - blawd
    - Catalyst
    - SQLite
    - Mason
    - Disqus
---

# Just What the World Needs: Another Blogging Engine

<div style="float: right">
    <img src="__ENTRY_DIR__/galuga_logo.png" alt="Powered by a Gamboling Beluga" width="300" />
</div>

It's a well-known fact in the computer world that any given application
will evolve until it develops emailing functionality. Likewise,
it seems that programmers are genetically predestined to, sooner or later,
churn out a blog engine.

I tried to resist. I honestly did.

I would have adopted [Wordpress](http://wordpress.org/http://wordpress.org/) 
a long time ago, but considering that I'm mostly blogging 
about my Perl adventures, I always saw as a moral imperative that 
my soapbox should match the cleaner I'm preaching for. 
Noble sentiment, isn't? Well... Cue in a quest of many years to find 
The Perfect Blogging Platforms.

I tried [Movable Type](http://www.movabletype.org/). While not not bad, I
wasn't overly in love with the way it creates the blog pages statically. I
didn't have the patience to deep-dive into its innards to learn how
I could write plugins for it either.  

So I waved MT good-bye, and moved to [Angerwhale](http://github.com/jrockway/angerwhale).
I confess, I was rather fond of the irate cetacean.  But there were some issues. 
And development dwindled.  And I wasn't entirely comfortable with the rude error
messages. After a while, I found myself looking again for another option.

(Esoteric side-story: there's something magic about Angerwhale. I removed the
application from my web server at least 2 years ago.  Since then, I changed
operating system *and* machine, and my web cache has been obliterated untold
times. Regardless, to this day I still can't load 
my blog via Firefox without having some ghost stylesheet mess up my layout. Or
have the publication dates of long gone entries plastered around. Spooky
stuff...)

Anyway. At that point, I joined [use.perl.org](http://use.perl.org).  The exposure to 
the community was truly awesome -- 
that was in the days before we had many Perl
aggregators like [Perl Iron Man](http://ironman.enlightenedperl.org/), 
[Perlsphere](http://perlsphere.net/) and [Planet Perl](http://planet.perl.org/) --
but the look and feel was... maybe a little bit dated.  Entries written in
raw html?  Claustrophobically minuscule input boxes for comments (that must be
also written using html)? Really? Eventually my restless heart
once more
yearned for new horizons.

I looked at [blawd](http://github.com/perigrin/blawd),
[blosxom](http://www.blosxom.com/), rjbs'
[Rubric](http://github.com/rjbs/rubric) and a few others. Some of them were
very close of what I wanted, but... not quite.  

I'm telling you, Goldilock has nothing on me.

By that time, I gave up and acknowledged it was futile to deny my dark urge
any longer. I drew the list of
core features I wanted in a blog engine:

* Able to write entries in Markdown (or such wiki-like format) or HTML.

* Entries that can be easily plopped in, and just as easily retrieved. Bonus points
if it is from the command line.

* RSS Feed (or Atom, I'm not picky).

* Commenting system.

* Template easily accommodating the addition of social widgets --  Iron Man badge, Twitter feed, Ohloh stack,
GitHub projects, etc.

* Tag-based classification system.

* Code pretty-printing.

I rolled my sleeves and... enter the 
[Gamboling Beluga](http://github.com/yanick/Galuga), or *Galuga* for short.

Galuga is a Catalyst application.  While it uses a temporary SQLite database
to serve the blog entries, the entries themselves are stored as 
[simple text files](http://github.com/yanick/blog_entries) that
look like this:

<pre code="plain">
url: galuga
format: markdown
created: 2010-09-23
tags:
    - Perl
    - Galuga
    - blog engine
    - Angerwhale
---

# Just What the World Needs: Another Blogging Engine

It's a well-known fact in the computer world that any given application
will evolve until it develops emailing functionality. Likewise, [..]
</pre>

I began writing its webpages' templates using Mason, but later took the occasion to 
try out [Template::Declare](cpan).  For the comment sub-system, I 
took the easy way out and outsourced the problem to Disqus.

It's still all very rough and experimental, but [this very
blog](http://babyl.dyndns.org/techblog) has been running
on it for a few weeks now and so far, so good.  While I doubt it's
going to change the face of the blogosphere, it managed to
finally placate my blog itch.  
After all those years, it feels darn good. :-)


