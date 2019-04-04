---
title: A Web Log Analyzer Called DuckFeet
url: duckfeet
format: markdown
created: 2011-12-29
tags:
    - Perl
    - DuckFeet
    - DBIx::Class
    - DBIx::Class::Candy
    - Moose
    - MooseX::Role::BuildInstanceOf
    - SQLite
    - Dancer
    - Dancer::Plugin::DBIC
    - jQuery
    - DataTable
---

In this modern world, time is a rare commodity. It's a well-known fact. It has
to be carefully budgeted and thriftily spent. There is never enough time
to do everything one wants to do, so we have to prioritize, pick what is
important and cut our loses on the rest.

I so wish my brain had gotten the memo on that.

It's not that my brainpan is teeming with brilliant ideas. It's just teeming
with... very insistent ideas. Ideas that will not let go until I help them
burst out of their cognitive cocoon and send them flutter free... and be
usually squished on the hard surface of the windshield of reality. But that's
okay. Success or failure, the idea is out and the inner choir of supplicants
is down by one, putting me one step closer to neuritic nirvana.

But I'm rambling. What I meant to say is: I have yet to find a web log
analyzer that totally satisfy me.  For the longest time, I've been 
using [awstats](http://awstats.sourceforge.net/). It's doing a fairly decent
job, but I keep thinking that it could be better. And while it's written in
Perl, it has, [as chromatic pointed
out](https://twitter.com/#!/chromatic_x/status/150034740639039490) a strong 1990 flavor, 
and has some architecture keypoints that make me twitch.
Not because they are that stupendously horrid, mind you; I'm just a very
twitch-happy kinda guy.

Incidentally, while writing this, I discovered on its website that awstats 
has [hit some snags with Perl
5.14](http://sourceforge.net/projects/awstats/forums/forum/43430/topic/4573686),
so like it or not, I might actually be forced to jump ship soon...

Of course, reason tells me I should just grit my teeth, use the fine tool for
as long as it's going to work, and focus my energy on better things.  
But, the voices... meanies that they are, they wouldn't let me rest. 

So you'll find on GitHub the [first esquisse of
DuckFeet](http://github.com/yanick/DuckFeet), a web log analyzer.  The name, by
the by, has absolutely nothing to do with [DuckDuckGo](http://duckduckgo.com).
I just went with the theme of webbed footprint and wabbling fowls.

## The Core

The major thing that gives me that cursed itch with awstats is how it uses a
semi-digested statistic file to keep track of its information.  I always
wanted to replace that with some honest-to-God database backend. The official
reason? To make searches easier to implement and extend, and more efficient.
The real reason? Because the voices told me so.

Consequently... DuckFeet's guts are SQLicious, and built as
[DBIx::Class](cpan) classes, sprinkled with wonderfully
tooth-decaying [DBIx::Class::Candy](cpan) on top.
In the repo, it's all under the
[DuckFeet::Schema](https://github.com/yanick/DuckFeet/tree/master/lib/DuckFeet/Schema)
namespace.  For the time being, there is only a handful of tables (hits, uris,
referers, agents and hosts), but it should be easily extendable to add any
type of information we might desire to throw in, but it should be easily
extendable to add any type of information we might desire to throw in.

## Importing the Log Entries

The main module `DuckFeet` is a [Moose](cpan) class that is
made up (using the awesome [MooseX::Role::BuildInstanceOf](cpan) of two
objects: the schema object, and an importer object.  The importer, for now, 
can only be of the
[Importer](https://github.com/yanick/DuckFeet/blob/master/lib/DuckFeet/Importer.pm)
class, but the functionality is meant to be turned into a role and implemented
by different classes when (or if) the need arises.

And with that, importing a regular Apache log is as easy as:

    #syntax: perl
    use strict;
    use warnings;

    use lib qw/ lib /;

    use DuckFeet;

    my $duck = DuckFeet->new(
        schema_args => [ 'dbi:SQLite:duck.db' ],
    );

    $duck->deploy_schema;

    # we have a need for speed
    $duck->schema->storage->dbh->do( 'PRAGMA journal_mode=WAL' );
    $duck->schema->storage->dbh->do( 'PRAGMA synchronous = OFF' );

    $duck->import_file( 't/data/access_log' );

By the way, those two *PRAGMA* setting up there? They make the difference
between an insertion rate of 3 entries per second and 150 entries per second. 
Seriously. If nothing else, this project reminded me why rtfm'ing is the first
optimization technique one should turn to.

## Displaying Our Statistics

We have a database shock-full of data to display. How to do it? Well,
web-based reporting feels like the most obvious way to go, so let's whip
out [Dancer](cpan) out of the toolbox.  The resulting web application,
[DuckFeet::Viewer](http://github.com/yanick/DuckFeet/blob/master/lib/DuckFeet/Viewer.pm),
is for now quite simple. It uses [Dancer::Plugin::DBIC](cpan) to interact
with the database and gather the number of hit for all visited pages. As I
want the data to be somewhat spiffy with the bare minimum of work involved,
the template leverages the very nice jQuery
[DataTables](http://datatables.net/) plugin to do the job. And lo and behold:

<div align="center"><img src="__ENTRY_DIR__/screenshot.png" alt="statistics
screenshot"/></div>
