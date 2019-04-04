---
title: Galuga Reborn!
url: galuga-reborn
format: markdown
created: 7 Jun 2013
tags:
    - Perl
    - galuga
---

<div style="float: right; width: 250px;">
<img src="__ENTRY_DIR__/galuga_reborn.png" alt="beluga on fire" /> 
<div style="font-size: small"><i>Like the mighty phoenix, Galuga is rebo-- hey, anybody else suddenly
hankering for S'mores?</i> </div> </div>

Nothing impedes more evolution than a working prototype. Don't believe
me? Just ask the coelacanth. 

In the same optic, a long time ago I had the itch to create my own blog
engine and, after some late night hacking, Galuga was born. Based on Catalyst
and using a git repository backend mixed with a database cache, it proved to
be a very satisfying piece of software.  Of course, a hacker's heart is a
fickle thing and, as time passed, I began to
dream of additional features and refactoring. But,it was working, so
there was no rush... 

So I began to leisurely poke and play, and more and more the
rewrite of Galuga became less about the blog engine itself, and more about 
experimentation and Proof-of-Concepting new technologies. First I intended to
migrate to [Dancer](cpan), but then [Dancer2](cpan) came along, so it
was a perfect opportunity to see how it would fare with a real application.
But the plugins I needed weren't ported to *Dancer 2* yet, so I had to look
into that. While I was at it, I could definitively use that [Template::Caribou](cpan)
that I keep rehashing. And, hey, how about making the database cache a little
easier to use? And how about
the grooming of entries, is there a Perl equivalent of jQuery that I could
leverage...?

Fast-forward to now, and the new incarnation of Galuga that just rendered that
blog entry for you sits is the tip of an iceberg-sized stack that 
contains an alarming high ratio of mad experiments and home-grown follies. For your
amusement, and as a warning to future generations, here's a brief overview of
the whole shebang, as well as notes and lessons I learned (or refused to) along the way.

## The Entries Repository

Something I absolutely wanted to retain from the original Galuga design is 
the use of a Git repository for the blog entries. Basically, each entry
is a directory in which a file `entry` contains the text of the entry plus its
metadata, written in a semi-YAML format:


``` yaml
title: Galuga Reborn!
url: galuga-reborn
format: markdown
created: 7 Jun 2013
tags:
    - Perl
    - galuga
---

Nothing impedes more evolution than a working prototype. Don't believe
me? Just ask the coelacanth. 
```

Nicely easy to edit manually, and equally easy to parse. All good stuff.

## Churn the Entries Into Cached Objects

Those files in the Git repository (which are accessed via
[Git::Repository](cpan), an always reliable workhorse) 
are great for the editing phase, but for the
web application they don't really cut it as we need to sorting, and
searching, and all that database-type kind of stuff. At first, I did the
obvious and created a small database schema that would be accessed via
[DBIx::Class](cpan) (interfaced with [Dancer2::Plugin::DBIC](cpan),
natch). But then I went for something something a little more simple:
[DBIx::NoSQL::Store::Manager](cpan), a Moose-aware thin layer on top
of [DBIx::NoSQL](cpan), which is itself a module that turns a SQLite
database into a NoSQL store (.. okay, so maybe I should have put quotes around
that 'simple' over there). Seriously, though, that module footprint on a regular Moose object is
minimal:

``` perl
package Galuga::Store::Model::Entry;

use Moose;

with 'DBIx::NoSQL::Store::Manager::Model';

has "path" => (
    traits => [ 'StoreIndex' ],
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has "uri" => (
    traits => [ 'StoreKey' ],
    isa => 'Str',
    is => 'ro',
    ...
);

has created => (
    traits => [ 'StoreIndex' ],
    isa => 'DateTime',
    is => 'ro',
    ...
);

has "sha1" => (
    ...
);


has "title" => (
    isa => 'Str',
    is => 'ro',
    ...
);

```

and yet those traits are sufficient to populate the entry store in a way that allows me
to query the entries via the attributes that I care about:

``` perl
# create a new entry
$store->create( Entry => ( path => $k ) )->store;

# then later on
my $entry = $store->get( Entry => $uri );

# and also
my @entries = $store->search('Entry')->order_by('created DESC')->all;
```

To make things even more interesting, *DBIx::NoSQL* actually uses
*DBIx::Class* under the hood to create the object store and its indexes, so
there is room for some dark, twisty magic in there if the need ever arise.
However, a word of caution: while the search functionality is supposed to
support `limit()`, it currently bombs if such a clause is used. It's
reasonable to assume that a patch will be submitted in a not too distant
future.

Oh, and I know what you think: "*geez, that object storage mechanism sounds a lot
like [KiokuDB](cpan)*". You're not wrong at all. In fact, at some point I
might push the insanity a notch further and change the *Git::Repository* /
*DBIx::NoSQL::Store::Manager* combo for a *GitStore* / *KiokuDB* amalgam.
But... that's something for another day. 

## Text Transmutation

For the parsing of the text, I went with [Text::MultiMarkdown](cpan),
which is [not as fast](http://neilb.org/reviews/markdown.html)
as the original [Text::Markdown](cpan), but does provide some additional
markups that I fancy. 

Talking of additional markups: further
munging of the text is done via [Web::Query](cpan), a Perl-space equivalent of
jQuery. The module is still young and a tad raw, but already works better (or
at least did for me) than [pQuery](cpan).  With it, it's pretty easy to
implement text shortcuts, like having

    [Galuga 2](play-perl:5117c3c7db9ca78359000031)

be inflated to 

``` xml
&lt;a href="http://questhub.io/perl/quest/5117c3c7db9ca78359000031" 
    title="Release Galuga 2, based on Dancer.">Galuga 2&lt;/a>
```

via something looking like:

``` perl

my $doc = Web::Query->new( 
    markdown( $text, { document_format => 'complete' } ) 
);

# the []() to <a> tag conversion is dealt with by 
# Markdown proper

$doc->find('a')->each(sub{ 
    my $href = $_->attr('href');

    return unless $href =~ s#^play-perl:(.*)#http://questhub.io/perl/quest/$1#;
    my $sha1 = $1;

    $_->attr( href => $href );
    $_->attr( class => $_->attr('class') . ' play_perl' );

    my $quest = eval { JSON::decode_json LWP::Simple::get
        "http://questhub.io/api/quest/$sha1" 
    } or return;

    $_->attr( title => $quest->{name} ) unless $_->attr('title');
    $_->text( $quest->{name} ) unless $_->text;
});
```

## The Dancing Core

The web application logic itself is minimal. So far, only three distinct actions
exist: the display of entries, the listing of all entries and the generation
of the feeds.  I suspect that things will grow in the future, but at the
moment, a simple [Dancer2](cpan) app module augmented 
by [Dancer2::Plugin::Feed](cpan) is all that it takes to put
that show on the road...

## The Pyrotechnical Department

... although that is not totally true, as there is still the rendering of the
information into web pages that remains to be done. That's dealt with with my
very own sliiightly wacky
[Template::Caribou](cpan) (and [Dancer2::Template::Caribou](cpan)).

While the template system still has its quirky edges (I'm still trying to find
an elegant way to have tag declarations percolate everywhere relevant), it
already support dancer-type layouts and make for very clean template bits. To
wit, this is the `inner.bou` template for this very page:

``` perl
div { attr class => "blog_entry"; 

    h1 { $self->entry->title };

    div { attr class => 'entry_times';
        span { "created: ". $self->entry->created->strftime("%B %e, %Y") };

        span { 
            ", last updated: ". $self->entry->last_updated->strftime("%B %e, %Y")
        } if $self->entry->last_updated 
            and $self->entry->last_updated->truncate( to => 'day' )
                ->compare( $self->entry->created->truncate( to => 'day' ) );
    };

    print ::RAW $self->entry->html_body;

    show('disqus');
}
```

## Not To Forget The Watchman

To monitor the whole thing, I tried my hand with [Ubic](cpan), which I
have to say is very nice. With the plugin [Ubic::Service::Plack](cpan),
setting the service for a Dancer app is delightfully trivial:

``` perl
use parent qw(Ubic::Service::Plack);
 
__PACKAGE__->new(
    server => 'Starman',
    app => '/home/galuga/Galuga/bin/app.pl',
    server_args => {
        port => 5000,
    },
    port => 5000,
    user => 'galuga',
    env => { 
        DANCER_ENVIRONMENT => 'production' 
    },
    ubic_log => '/var/log/techblog/ubic.log',
    stdout   => '/var/log/techblog/stdout.log',
    stderr   => '/var/log/techblog/stderr.log',
);
```

## The Experiment Is Nowhere Over...

... but for the moment I'll take great relish in [claim this particular
quest](play-perl:5117c3c7db9ca78359000031) a success.

Updates, mind you, are indubitably going to appear before long. Until then, as
usual, the code is [on GitHub](gh:yanick/Galuga). For peeps who were using
Galuga First Generation (hi Tommy!): don't be too horrified: I created a `first_generation` branch
so that it's possible to reroute around my... innovations.

