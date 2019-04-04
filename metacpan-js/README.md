---
title: MetaCPAN JavaScript API
url: metacpan-js
format: markdown
created: 2013-04-14
tags:
    - Perl
    - MetaCPAN
---

Sometimes, it's humongous revolutions. Most of the time, it's itsy bitsy
evolution steps. Today's hack definitively sits in the second category, 
but I have the feeling it's a little dab of abstraction that is going to 
provide a lot of itch relief.

You see, [MetaCPAN](https://metacpan.org) does not only have a pretty face,
but also has a [smashing backend](https://github.com/CPAN-API/cpan-api/wiki/Beta-API-docs) 
that can be used [straight-up](http://explorer.metacpan.org/) for fun and
profit.

Accessing REST endpoints is not hard, but it's a little bit of a low-level
chore.  In Perl space, there is already [MetaCPAN::API](cpan) to 
abstract

    #syntax: perl
    my $ua = LWP::UserAgent;
    my $me = decode_json( 
        $ua->get( 'https://api.metacpan.org/author/YANICK'
    )->content;

into

    #syntax: perl
    my $mcpan = MetaCPAN::API;
    my $me = $mcpan->author('YANICK');

In JavaScript-land? Well, there was jQuery, of course:

    $.get('https://api.metacpan.org/author/YANICK').success( function(data) {
        alert( 'hi there ' + data.name );
    });

But now there is also [metacpan.js](https://github.com/yanick/metacpan.js): 

    $.metacpan().author('YANICK').success( function(data) {
        alert( 'hi there ' + data.name );
    });

The plugin is still very simple and only implements `author()`, `module()`,
`release()` and `file()`. And each of those methods is nothing but a glorified
wrapper around the underlying `$.ajax()` calls. But, then again, isn't the road to
heaven paved with glorified wrappers? (which could be more of an indication of
the terrible littering habits of angels than anything else, mind you) 

Enjoy (and/or fork, depending on how much the current code is already
scratching your own itch)!
