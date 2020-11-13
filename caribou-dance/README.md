---
url: caribou-dance
created: 2012-12-03
tags:
    - Perl
    - Dancer
    - Template::Caribou
---

# Dance For Me, Caribou, Dance!

This is a work in progress, but it's so much on the far side of wicked, I
*have* to share.

So, I'm working on the rewrite of [Galuga](https://github.com/yanick/Galuga).
Which is itself a big fat excuse to play with my other pet projects, like
[DBIx::NoSQL::Store::Manager](cpan) and
[Template::Caribou](http://babyl.dyndns.org/techblog/entry/caribou). Tonight,
I was playing with the latter, and I thought "*It's kinda a pain to define all
the templates within the class file. Wouldn't it be nice to define them in
individual files instead?*".  Fair point, and easily to do with the help of a
role:

<galuga_code code="perl">Files.pm</galuga_code>

Then I thought, "*Instead of having to run a script over and over again as
I create those templates, wouldn't it be awesome to generate an ad-hoc web app
that would refresh in real time?*". So I went ahead and created a second role:

<galuga_code code="perl">DevServer.pm</galuga_code>

Let's create a template class to go with the season (by the by, you are
following all the [Perl Advent calendars, right?](http://perlnews.org/2012/12/advent-calendars/)).

<galuga_code code="perl">Wishlist.pm</galuga_code>

And now, the cool stuff happens. First, we create an object and fire up its
very own web application:

```bash
$ perl -MWishlist -e'Wishlist->new( wishlist => [ "tiger socks", "alpaca wool", "a pony" ])->dev_server'
HTTP::Server::Simple::PSGI: You can connect to your server at http://localhost:3000/
```

And with that...

```bash
$ echo 'html{ body { p{ "hello there" } } }' > templates/main.bou

$ curl localhost:3000/main
<html><body><p>hello there</p></body></html>

$ echo 'ul { li { $_ } for @{$self->wishlist} }' > templates/list.bou

$  curl localhost:3000/list
<ul><li>tiger socks</li><li>alpaca wool</li><li>a pony</li></ul>

$ echo 'body { show("list") }' > templates/main.bou 

$  curl localhost:3000/main
<body><ul><li>tiger socks</li><li>alpaca wool</li><li>a pony</li></ul></body>
```

Okay, I confess, that display is slightly rigged: an already existing template has to be
hit so that the new ones are registered. But still, you have to admit, it's
all still pretty darn cool.

In all case, all that magic haven't made it yet to the master branch of
`Template::Caribou`, but if you want to experiment with the code, it's all
there in its [own
branch](https://github.com/yanick/Template-Caribou/tree/dance-like-a-madman).
