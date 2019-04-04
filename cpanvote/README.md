---
title: CPANvote is live
url: cpanvote-is-live
format: markdown
created: 2011-03-05
tags:
    - Perl
    - cpanvote
---

<img src="__ENTRY_DIR__/cpanvote.png" alt="cpanvote logo" 
    width="200"
    style=" float: right; " />

If you recall, last year, at roughly the same date, I had a few days worth of free time
and, on a whim, decided to hack together a quick prototype of 
a [CPAN voting web service][1]. The result wasn't too shabby (or so
I like to think), but as it often happens, the tide of tuits ebbed away
and the prototype remained such.

Fast-forward to last December and Olaf Alders' blog entry
about [search.metacpan.org][2]. That blog entry caught my eye,
not only because the project looked slick as hell, 
but because an upvoting/downvoting system
was on its roadmap. Never the one to turn my back to shameless self-promotion, 
I mentioned my blog entry and mini-project in the comment section,
As luck had it, 
my views were very much in line with
what the *metacpan* cabal was envisioning, and I was told that, if I was willing,
I was welcome to give it a try.

As a subsequent [update from Olaf][3] hinted at, that's an offer I couldn't
let pass. So, in the last two months, I've been a busy bee.

[1]: http://babyl.dyndns.org/techblog/entry/cpanvote-a-perl-mini-project
[2]: http://blogs.perl.org/users/olaf_alders/2010/12/searchmetacpanorg-building-a-sexier-cpan-search.html
[3]: http://blogs.perl.org/users/olaf_alders/2011/02/metacpan-status-update.html

## A Quick Recap: Mission Statement

*cpanvote*'s core goal is to make trivially easy for 
people to vote on Perl distributions. To achieve
that, I decided to build the application around the two 
precepts:

* *Simple rating mechanism.* The voting is reduced to 
a ternary choice: *yea*, *nay* or *meh*. Optional details will
be grafted unto it -- like recommending an alternative distribution --
but the basic question is "do you like/recommend this distribution?".

* *Symbiotic existence.*  Voting and accessing voting information
must be possible without having to visit a special site. The information
must be provided via a web service, so that anyone can build
applications/widgets/whatever to interact with it, and  the end-goal is 
have the whole thing visible from the CPAN searching sites.

## Where Are We, Now?

As of this morning, `cpanvote.metacpan.org` is live! It's extremely
alpha, will doubtlessly experience API changes, go up and down like a kangaroo
on a pogo stick and drop all its data a few times, but it's there and can be
played with.

For now, I'll not discuss the back-end web service,
but will rather go straight to the shiny and show you how 
it can already be used on [search.cpan.org](http://search.cpan.org). 

First thing first. The interaction  with `search.cpan.org` is done
via a Greasemonkey script, which is available at 
[cpanvote.metacpan.org](http://cpanvote.metacpan.org/static/cpan_vote.user.js). 

If you 
install it, next time you access a distribution page on `search.cpan.org`,
the headers should have a new 'CPAN Votes' row:

![search.cpan.org with cpanvote](__ENTRY_DIR__/cpanvote1.png)

As we are not authenticated, we can only see the 
yea/meh/nay tallies. Following our symbiotic approach, 
we are delegating authentication to
what's already out there. For the time being, we are using Twitter, 
but the system is designed such that we can add expand to other 
services (*openid*, *Bitcard*, *Facebook*, etc) as well.

Anyway, back to the current state of affairs. If we click on the 
authentication link, we are brought to the usual Twitter 
authorization webpage:

![Twitter authorization](__ENTRY_DIR__/cpanvote2.png)

Don't worry, `cpanvote` is only interested in having credentials. Nothing
will be done with your Twitter account.  Clicking on 'allow' redirects
us back to the `search.cpan.org` page we were at, but with a big difference: now
we can vote!

![voting enabled](__ENTRY_DIR__/cpanvote3.png)

Voting is done by clicking on the smileys. The 'instead of' field is
for recommending an alternative to the current distribution. At the moment,
no validation is made to ensure the suggestion is a valid module, but it'll
come soon. 

Of course, all interactions are ajaxy and appear immediately:

![voting enabled](__ENTRY_DIR__/cpanvote4.png)

## What's Coming Down the Pipe

*Looots* of things.

On the front-end side, 
there is obviously some work to be done to make the GreaseMonkey interface
slicker. A `metacpan` variant of the GMscript should also be 
available soon.

On the back-end side, documenting the current minimal RESTful interface is at
the forefront. When this is done, we can begin to build on it and 
provide all kind of ways to access the voting statistics.  

So expect a lot of fun stuff in the near future. If you want to 
casually help, install the Greasemonkey script, give the 
voting system a whirl and provide feedback as to how you
find it, and what you'd like to see it do next.  And if you want
to roll up your sleeves and pitch in, the [CPAN API mailing 
list](http://groups.google.com/group/cpan-api) is where it's at --
don't be shy to come on in and join the fray!

