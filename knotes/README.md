---
title: Migrating Knotes data the hard way
url: knotes-migration
format: markdown
created: 11 Jun 2014
tags:
    - Perl
---

This entry is a quick one, but that could come in handy for anyone migrating 
to Ubuntu 14.04. 

Over the week-end, I upgraded Siduri, my wife's computer,
from Ubuntu 12.04 to Ubuntu 14.04. Always a harrowing 
procedure. I mean, I mess up my computer, that's on me. But to
bring somebody else's workhorse on the operation table, fully knowing that
any wrong decision could lead up to a pot of glue? That's terrifying.

Anyway, cold sweat aside, most of the upgrade went fairly well.
With the unavoidable few exceptions. Includind, this time around, KDE's Knotes, which changed how it 
stores data, and whose migration program 
burped an error and failed to do the one job is was made to do. A little bit
of research revealed that it's a known issue, but that the fix is only
coming with the next version of KDE.

Well, crap.

As my wife had a good number of notes, that just wouldn't do. Fortunately, the
gods were smiling on us. On closer inspection, it turns out that Knotes senior
was using an ICS calendar file to keep its notes, whereas Knotes junior
moved to a maildir structure with each note being an email file. 
That's all standard stuff. Which is quite welcome, because it means that I can
reach for my favorite roll of duct-tape and come up with a quick bridge
between the two:

``` perl
use 5.20.0;

use experimental 'postderef';

use warnings;

use Data::ICal;
use Path::Tiny;
use Email::Simple;

path( $ENV{HOME}, '.local/share/notes/new' )
    ->child( $_->property('uid')->[0]->value )
    ->spew(
        Email::Simple->create( 
            header => [
                From => 'old kde <kde@(nowhere.com)>',
                Subject => $_->property('summary')->[0]->value,
            ],
            body => $_->property('description')->[0]->value
        )->as_string
    ) 
        for Data::ICal->new(
                # Data::ICal doesn't like the PRIORITY property
            data => path( $ENV{HOME}, '.kde/share/apps/knotes/notes.ics')
                    ->slurp =~ s/^PRIORITY:\d+\r\n//mr
        )->entries->@*;
```

In our case, that seems to have done the job rather nicely. All data has been
reported as being accounted for and, except for a few unicode funny characters, 
unmolested. 
