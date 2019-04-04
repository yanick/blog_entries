---
title: Embedding Perl in SQLite
url: sqlite-perl
format: markdown
created: 20 Feb 2012
tags:
    - Perl
    - SQLite
---

As you may remember, recently I took the fancy to 
[implement a TAP emitter in SQLite](http://babyl.dyndns.org/techblog/entry/sqlitetap).
SQLite's extension framework makes the task fairly easy, but working
in C for the first time in, oh God..., let's just say a long time made me
realize how rusty my low-level language skills are. String manipulations are
especialy brutal after years of Perl. Allocate memory, stitch things together,
don't forget to free the memory afterward. Lather, rince, repeat. 
*Blergh.* At some point I found myself waving my hands at the ceiling and 
wishing aloud that I could use Perl from within SQLite.

And then I froze...

The extension system is good for anything written in C. So, in theory, I
could -- probably *shouldn't* -- but I could write a thin wrapper for a Perl 
interpreter.

At that point, I had no choice. The idea was so preposterous, I had to try it.

## Unholy Union

As I mentioned, my C is quite rusty and my afinity to XS is, shall we say,
minimal.  But after banging my head a lot over `perlembed`, and staring at
`perlapi`, I was able to come up with:

    #syntax: cpp
    #include "sqlite3ext.h"
    SQLITE_EXTENSION_INIT1;

    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include <EXTERN.h>
    #include <perl.h>

    static PerlInterpreter *my_perl;

    void init_perl () {
        char *embedding[] = { "", "-e", "0" };

        PERL_SYS_INIT3(NULL,NULL,NULL); 
        my_perl = perl_alloc();
        perl_construct( my_perl );

        perl_parse(my_perl, NULL, 3, embedding, NULL);
        perl_run(my_perl);
    }

    static void sql_perl_do (
        sqlite3_context *ctx,
        int num_values,
        sqlite3_value **values 
    ) {
        SV *result = eval_pv( 
            sqlite3_value_text( values[0] ), TRUE 
        ); 

        sqlite3_result_text( 
            ctx, SvPV_nolen(result), sv_len(result), NULL 
        );
    }

    int sqlite3_extension_init( 
        sqlite3 *db, 
        char **error, 
        const sqlite3_api_routines *api 
    ) {
        SQLITE_EXTENSION_INIT2(api);

        init_perl();

        sqlite3_create_function( 
            db, "perl_do", -1, SQLITE_UTF8, 
            NULL, sql_perl_do, NULL, NULL
        );

        return SQLITE_OK;
    }


I am the firs to admit, the code is mostly cargo cult, stitched together with
guesses and hopes. But it goes survive the compilation dance:

    #syntax: bash
    $ gcc -c -fPIC sql_perl.c \
        `/usr/bin/perl -MExtUtils::Embed -e ldopts -e ccopts`
    $ gcc -shared -o sql_perl.sqliteext \
        sql_perl.o /usr/lib/libperl.so

So far, so good. But.. does it blends? 

    #syntax: bash
    $ cat perl.sql
    .load sql_perl.sqliteext

    select perl_do('
        $x = "whfg nabgure fdy unpxre";
        $x =~ y/a-z/n-za-m/;
        $x;
    ');

    $ sqlite3 < perl.sql
    just another sql hacker


<div>... In the words of dear ol' Cassidy: "<div style="display: inline-block; position: relative;">fuck<div style="position: absolute; background: black; width: 90%; height: 6px; top: 7px;"></div></div>in' groovy."</div>

