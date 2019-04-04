---
title: A First Stab at SQLiteTAP
url: sqlitetap
format: markdown
created:  13 Feb 2012
tags:
    - Perl
    - PgTAP
    - TAP
    - Oracle
---

The [main presentation](http://www.slideshare.net/spurkis/tapharness-friends) of the last tech meeting of Ottawa.pm, 
was given by [Steve Purkis](http://search.cpan.org/~spurkis/) and was about
[TAP::Harness](cpan) and its friends.  After Steve properly awed us with
the joy and wonders of [TAP](http://testanything.org/wiki/index.php/Main_Page)
and its ecosystem,
he exorted us to go forth and create new TAParific things.

Don't people know by now how ill-advised it is to say such things when I'm
around?

As luck would have it, there was already a TAP-related project simmering in my
todo back-burner.  Not so long ago, [David E. Wheeler](http://search.cpan.org/~dwheeler/) came up with
[PgTAP](http://pgtap.org), which provides PostgreSQL with the functions to
write TAP-emitting unit tests.  Yes. Unit testing. Done with straight SQL
queries. How cool is that?

Since then,
[MyTAP](http://justatheory.com/computers/databases/mysql/introducing_mysql.html),
a port of PgTAP for MySQL, also saw the light of day.  But, so far, nothing for
Oracle. Which is kinda of a shame, as such a thing could potentially make a
lot of my coworkers squeal like little children on Christmas morning. So I
decided to roll my sleeves and have a go at oraTAP, news of which was
immediately met with wild displays of jubilation throughout the land. 

... Okay, not really, but
there *was* a single yet heart-felt [yay](https://twitter.com/#!/gwenshap/status/162938425866063874) 
that was heard coming from the peanut gallery. 

But Oracle is a massive and, shall we say, venerable application that can be
daunting. So I thought that maybe experimenting first with a database
application of less magnitude might be a wise warm-up exercise.  Something
like... SQLite, perhaps?

And that's what I did. My first stab at SQLiteTAP is [on
GitHub](https://github.com/yanick/SQLiteTap). I'm writing it as a SQLite extension,
so I had to brush up very rusty C skills.  But after a few hours pouring over
the documentation, and poking here and there, I have a working implementation
of '`plan`' and '`ok`'. Nothing earth-shattering, I'll concede, but a nice start
nonetheless.

To use the extension, you first have to compile it on your machine.  The
project includes a barebone Makefile that works for my Ubuntu box, but
basically your local variation on

    #syntax: bash
    $ gcc -c sql_tap.c && ld -shared -o sql_tap.ext sql_tap.o

should do the trick.  After that, you just need to load the extension and run
the tests just like with PgTAP.  For example, if we use the following test
file

    #syntax: sql
    .load sql_tap.ext

    select plan(6);

    select ok( 1, "this passes" );
    select ok( 0, "this fails" );

    create table puppies (
        name text,
        cuteness number
    );

    insert into puppies values ( 'lassie', 5 );
    insert into puppies values ( 'spot', 7 );

    select ok( cuteness >= 5, name || ' is darn cute' ) 
        from puppies;

    select ok( 1 );
    select ok( 0 );

then we'll get

    #syntax: bash
    $ sqlite3 < test.sql
    1..6
    ok 1 - this passes
    not ok 2 - this fails
    ok 3 - lassie is darn cute
    ok 4 - spot is darn cute
    ok 5
    not ok 6

Nifty, no?

