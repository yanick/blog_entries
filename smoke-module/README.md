---
title: Smoked Modules, Montréal-style
url: smoke-module
format: markdown
created: 4 Oct 2012
tags:
    - Perl
    - smoking
---

If you recall, in [our last
episode](http://babyl.dyndns.org/techblog/entry/test-dancer-plugins) 
I hacked together a quick solution to smoke all of Dancer's plugins and know
how they fare, with regard to Dancer 1 versus Dancer 2.  

After that blog
entry, I thought it would be fun to revisit the problem and try to implement a
more general solution. The experiment, I
decided, would have the following goals: at its base it would have to be
generic enough to be able to smoke any module, and provide the flexibility
required to be easily extensible. To exercise that said extensibility, I would
have to implement two plugins: one that retrieves the module-to-test from a
[Pinto](cpan) repository, and the other that saves the testing results in
a database.  So, basically, have all the goodies of the hack, but rephrased in
a way that will allow me to use it for other, future nefarious ends.

I'll not keep you in suspence: the experiment fared quite well (or so I like
to think) and is now [available on
GitHub](https://github.com/yanick/Smoke-Module). It's full of stubbed
functionality and still need much work, but it's doing something. Here, let me
show you.

## Here, Smoke That

At the core, we want the raw smoking functionality: we want to shove a tarball
in, and we want the tap report out. So that's what we're going to have our
main module, `Smoke::Module`, do (and you have **no** idea how hard it was for
me not to call that module `Smoked::Meat`).

<galuga_code code="perl">Module.pm</galuga_code>

As usual, the trick is to find the modules that do the hard parts, and glue
them together.  The tarball is extracted via the good services of
[Archive::Tar](cpan), in a directory kindly provided by
[MooseX::Role::Tempdir](cpan). We run the distribution
`Build.PL/Makefile.PL` with the assistance of [IPC::Run3](cpan), the 
running of the test and creation of the TAP archive is delegated to 
`prove`, and the slurping back of said archive is done by 
[TAP::Harness::Archive](cpan), which gives us a
[TAP::Parser::Aggregator](cpan) with all the goods. And thanks
to the lazy builders sprinkled everywhere, using the module turns out to be
very short and sweet:

    #syntax: bash
    $ perl -Ilib -MSmoke::Module \
        -E'say Smoke::Module->new( tarball => shift )->test_status' \
        Dancer-Plugin-Cache-CHI-1.3.1.tar.gz 
    t/00-compile.t ...... ok   
    t/basic.t ........... ok     
    t/honor-no-cache.t .. ok   
    t/hooks.t ........... ok   
    t/key-gen.t ......... ok   
    t/namespaces.t ...... ok   
    All tests successful.
    Files=6, Tests=42,  4 wallclock secs ( 0.04 usr  0.01 sys +  1.84 cusr  0.17 csys =  2.06 CPU)
    Result: PASS

    TAP Archive created at /tmp/sae8spnE_K/tap.tar.gz
    PASS

Uh. Okay, I still have to figure out why `prove` won't shut up, but beside
that, ain't that sweet?

## For Good Smoking, You Have To Have Good Tar(balls)

Now that we have the core, let's turn our attention to our plugins. For the
first one, we want to turn things around a little bit. Instead of providing
a tarball directly, we'll provide a module name (and possibly a version), and
let the system figure out how to borrow it from `Pinto`.

<galuga_code code="perl">Pinto.pm</galuga_code>

The sneaky bit in that role is how we change the nature of the `tarball`
attribute. Usually, roles aren't supposed to mess with the base class's
attributes that way, but thanks to
[MooseX::Role::AttributeOverride](cpan) we do have a way to against the
fundamental laws of Nature. Worked for Viktor Von Frankenstein, don't see why
it wouldn't for us...

## And Pipe The Results To The Database

... ye gods, I can't believe I just made that pun. I'm so ashamed, I wish I
could crawl under the carpet or disappear in a puff of sm-- aaaanyway...

So, yeah, last bit: intercept the results, and store them in a database. And
for that kind of job, I'm
very quickly growing quite fond of my little [DBIx::NoSQL::Store::Manager](cpan)
module:

<galuga_code code="perl">Store.pm</galuga_code>

Most of the code in that module is there to oil the gears of
[MooseX::Storage](cpan); to tell it which attributes which aren't worth
serializing, and how to serialize the different attribute objects.

## Get The Pieces Together

We could probably still find a way to run the base class with all the roles as
a one-liner, but that would be just be show-off, so instead, let's do things
properly, the long-hand way:

    #syntax: bash
    $ cat smoker.pl
    #!/usr/bin/env perl

    use 5.10.0;

    package Smoked;

    use Moose;

    extends 'Smoke::Module';
    with 'Smoke::Module::Pinto';
    with 'Smoke::Module::Store';

    say __PACKAGE__->new( 
        package_name  => $_,
        debug         => 1,
        log_to_stdout => 1,
    )->run_tests for @ARGV;

    $ ./smoker Dancer::Plugin::Cache::CHI
    [6295] extracting tarball to /tmp/hREOWmENuC
    [6295] Build.PL detected
    [6295] Created MYMETA.yml and MYMETA.json

    [6295] Creating new 'Build' script for 'Dancer-Plugin-Cache-CHI' version '1.3.1'

    [6295] Building Dancer-Plugin-Cache-CHI

    PASS

    $ sqlite3 test.sqlite .dump
    [..]
    INSERT INTO "__Store__" VALUES('Smoked','Dancer::Plugin::Cache::CHI : v1.3.1 : Thu Oct  4 21:32:32 2012','{
    "tap_report" : {
        "todo_passed" : 0,
        "exit" : 0,
        "descriptions_for_todo_passed" : [],
        "failed" : 0,
        "descriptions_for_parse_errors" : [],
        "descriptions_for_total" : [
            "t/00-compile.t",
            "t/basic.t",
            "t/honor-no-cache.t",
            "t/hooks.t",
            "t/key-gen.t",
            "t/namespaces.t"
        ],
        "descriptions_for_todo" : [],
        "descriptions_for_planned" : [
            "t/00-compile.t",
            "t/basic.t",
            "t/honor-no-cache.t",
            "t/hooks.t",
            "t/key-gen.t",
            "t/namespaces.t"
        ],
        "todo" : 0,
        "parse_order" : [
            "t/00-compile.t",
            "t/basic.t",
            "t/honor-no-cache.t",
            "t/hooks.t",
            "t/key-gen.t",
            "t/namespaces.t"
        ],
        "planned" : 42,
        "descriptions_for_skipped" : [],
        "parse_errors" : 0,
        "descriptions_for_exit" : [],
        "descriptions_for_passed" : [
            "t/00-compile.t",
            "t/basic.t",
            "t/honor-no-cache.t",
            "t/hooks.t",
            "t/key-gen.t",
            "t/namespaces.t"
        ],
        "parser_for" : {
            "t/00-compile.t" : null,
            "t/basic.t" : null,
            "t/honor-no-cache.t" : null,
            "t/hooks.t" : null,
            "t/key-gen.t" : null,
            "t/namespaces.t" : null
        },
        "passed" : 42,
        "total" : 42,
        "skipped" : 0,
        "wait" : 0,
        "descriptions_for_failed" : [],
        "descriptions_for_wait" : []
    },
    "package_name" : "Dancer::Plugin::Cache::CHI",
    "package_version" : null
    "tarball" : "/home/yanick/pinto/authors/id/Y/YA/YANICK/Dancer-Plugin-Cache-CHI-1.3.1.tar.gz",
    "perl_exec" : "/usr/local/soft/perlbrew/perls/perl-5.14.2/bin/perl",
    }
    ');
    [..]

Now, picture few more plugins, a Dancer front-end, and wouldn't you agree this
could become interesting real fast?


