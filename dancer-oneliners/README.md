---
title: Web Service one-liners with Dancer
url: dancer-oneliners
format: markdown
created: 2012-09-10
tags:
    - Dancer
    - Perl
---

Today, I had [some bit of fun](https://twitter.com/yenzie/status/245242218368094208) and created a micro-web service as a one-liner.
Something like:

    #syntax: bash
    $ perl -MDancer -e'get"/",sub { "current time: " . localtime }; dance'

But then I thought that using almost 70 characters for a web service was
awfully long-winded. Surely there was a way to make our Dancer more efficient.
But how? How about... by getting a MC involved?

<galuga_code code="perl">C.pm</galuga_code>

With that little module, I can now do

    #syntax: bash
    # in one console

    $ perl -Ifiles -MC -e'sub index { "the time is " . localtime }'
    >> Dancer 1.3095 server 5780 listening on http://0.0.0.0:3000
    == Entering the development dance floor ...

    # and in the next

    $ curl localhost:3000
    the time is Mon Sep 10 22:22:00 2012

Or try for a tad more sophisticated:

    #syntax: bash
    # in the first console

    $ perl -Ifiles -MC
    my $secret;

    get '/' => sub { $secret };

    put '/*' => sub { ( $secret ) = splat };
    ^D

    >> Dancer 1.3095 server 5961 listening on http://0.0.0.0:3000
    == Entering the development dance floor ...

    # and in the second

    $ curl -X PUT http://localhost:3000/abracadabra
    1

    $ curl http://localhost:3000
    abracadabra

So, yeah, I'm back. Missed me? :-)
