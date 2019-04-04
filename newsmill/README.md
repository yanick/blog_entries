---
title: Newsmill (aka an excuse to play with shinies)
url: newsmill
format: markdown
created: 2013-01-20
tags:
    - Perl
    - Perlweekly
---

If you are subscribed to the [Perl Weekly Newsletter](http://perlweekly.com/),
you probably noticed that I've been drafted as a co-editor. As a side-effect,
Gabor and I began to discuss at how the newsletters' data are being stored (right
now [it's all JSON](https://github.com/szabgab/perlweekly/tree/master/src),
which is handy to parse via scripts, but sucky to
edit manually), and
how it can be streamlined/improved to allow easy collaborative work.

As a side-effect of that, I began to toy with the generalized problem of
newsletter management and, for giggles, began to write a system for that. 
The result is [Newsmill](https://github.com/yanick/newsmill), which is for
now only a stubby playground. But it's a playground full of fun, colorful 
rides, so I thought you might like to have a tour...

## First, Let's Have a Database

The first step I took was to create a database schema to represent the 
issues of the newsletter and the various articles. As the perlweekly sources
were already JSONified, I thought of using [DBIx::NoSQL](cpan) or
[DBIx::NoSQL::Store::Manager](cpan), but ultimately decided to stay 
traditional. So [DBIx::Class](cpan) it is, with a
generous sprinkling of [DBIx::Class::Candy](cpan) on top, such that 
the table classes look like:

    #syntax: perl
    package Newsmill::Schema::Result::Article;

    use strict;
    use warnings;

    use DBIx::Class::Candy -autotable => v1;

    __PACKAGE__->load_components(qw/InflateColumn::DateTime/);

    primary_column article_id => {
        data_type => 'int',
        is_auto_increment => 1,
    };

    column title => {
        data_type => 'varchar',
        size => 200,
        is_nullable => 0,
    };

    column url => {
        data_type => 'varchar',
        size => 200,
        is_nullable => 0,
    };

    column publication_date => {
        data_type => 'date',
        is_nullable => 1,
    };

    column description => {
        data_type => 'text',
        is_nullable => 1,
    };

    has_many article_tags => 'Newsmill::Schema::Result::ArticleTag', 'article_id';
    many_to_many tags => 'article_tag', 'tag';

    1;

It also gave me the occasion to look at [DBIx::Class::Migration](cpan),
which provides a very, very nice front-end for the powerful but byzantine 
[DBIx::Class::DeploymentHandler](cpan). Of course, this being the 
first version of the application, I didn't have a lot of migration stuff
to try out, but at least I can do

    #syntax: bash
    $ dbic-migration diagram -Ilib --schema_class Newsmill::Schema

and obtain

<div align="center"> <img src="__ENTRY_DIR__/schema.png" alt="schema
graph"/></div>

which is neat.

## Then, Let's Populate It

As the Perl Weekly entries are so nicely JSON formatted, slurping them all
into the database is no great hardship with the help of a [little script](https://github.com/yanick/Newsmill/blob/master/bin/import_newsletters.pl):

<galuga_code code="perl">import_newsletters.pl</galuga_code>

That done, we only have to point the script to the right directory and:

    #syntax: bash
    $ perl -Ilib ./bin/import_newsletters.pl 
    importing 1
            add section Headlines
                    add article Nice progress in the development of MetaCPAN
                    add article Rakudo Star 2011.07 released with 10%-30% improvement in compile and execution speed
            add section Articles
                    add article Whitepaper from ActiveState: Perl and Python in the Cloud
                    add article Padre on OSX
                    add article OSCON Perl Unicode Slides
                    add article Moose is Perl: A Guide to the New Revolution
                    add article YAPC::Europe Preview
                    add article GSoC - The Perl 6 podparser branch has landed
            add section Discussions
                    add article To Answer, Or Not To Answer....


## Show Them What We've Got

Eventually, I want `Newsmill` to be able to take article submission from
external peeps, have a voting system, et cetera and so forth, but let's pace
ourselves. For now, we have a database shockful of newsletters, so it might be nice to
see them. In consequence, let's create a web front-end for the newsletters:

<galuga_code code="perl">WebApp.pm</galuga_code>

Note that by now I've left the bleeding edge of technology and boldly jumped
into the arterial spray of the future. The web framework? [Dancer
2](https://github.com/perldancer/Dancer2).
The templating system? My little pet `Template::Caribou`. I'll not bore you
with the details of `Template::Caribou` (that's coming in my next blog entry),
so I'll just mention that the `Entry` template class looks like

<galuga_code code="perl">Issue.pm</galuga_code>

And the main page template segment is:

<galuga_code code="perl">page.bou</galuga_code>

Oh, yes, HTML5 [Bootstrap](http://twitter.github.com/bootstrap/) has been thrown in the mix too, natch.

And the result:

<div align="center">
<img src="__ENTRY_DIR__/screenshot.png" alt="Newsletter sample" /></div>

Not bad, I daresay, considering that there is no stylesheet applied beyond the basic Bootstrap
stuff.

