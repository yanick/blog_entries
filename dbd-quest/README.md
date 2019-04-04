---
title: The DBD-Quest of Unknown Kadath
url: dbd-quest-of-unknown-kadath
format: markdown
created: 2011-07-28
tags:
    - Perl
    - DBD::Oracle
---

I already aluded to the fact in a few
posts already, but just to make it a wee bit more
public: a few weeks ago, someone had a lapse of common sense
and knighted me Maintainer of <a href="https://metacpan.org/release/DBD-Oracle">DBD::Oracle</a>.

*mouahahaha*

<i>\*ahem\*</i> I mean, I'm honored to be allowed to at the wheel of what
is one of the most venerable battleships of the CPAN armada, and hereby swear
to serve her at the best of my abilities.

While I'm not exactly a database expert, and my knowledge of OCI could only
be charitably defined as nascent, I have the good luck of being embedded smack in the
middle of a <a href="http://pythian.com">wicked hive of SQL and db
wizardry</a>, and some of the sharpest blades in the armory are actually
acutely keen to contribute to the project. In consequence, my strategy for
the time being will mostly for me to man the administrative part of the
maintenance (bug triage, release grooming, repository overseeing -- y'know, all the
fun stuff), and let better minds take care of the real hard parts.

## Join the fun!

Of course, one can never have too many minds, so if you want to join the fun,
you are quite welcome to.  "How?", you ask?  Oh, there are quite a few ways:

* **Mailing lists.** <a href="http://lists.perl.org/list/dbi-dev.html">dbi-dev</a>
is the core mailing list for DBI development. However, since quite a few of
the new potential contributors will need coaching in the ways of the CPAN,
I also created a <a
href="http://groups.google.com/group/dbd-oracle">dbd-oracle</a>. Expect
the deep, interesting discussions to happen on the former list, and the
nitty-gritty day-to-day details to be ironed out on the latter.

* **Bugs.** Bugs are recorded on <a href="https://rt.cpan.org/Public/Dist/Display.html?Name=DBD-Oracle">rt.cpan.org</a>.
I've also made a copy of the list using <a
href="https://github.com/yanick/DBD-Oracle/issues">GitHub Issues</a>, so that
I could sort bugs by architecture, versions and whatnots. Ever feel bored?
Pick a bug that is supposed to affect your architecture, try to reproduce it,
and have a go at fixing it.

* **Repositories.** The official repository is still at <a href="http://svn.perl.org/modules/dbd-oracle/">svn.perl.org</a>.
There is also a <a href="https://github.com/yanick/DBD-Oracle">GitHub
clone</a>. You want to write a patch? Checkout the svn repo and push the patch
via RT, or fork the GitHub repo and go wild.

## Sneak Preview

One of the things I really, really want to do is to make DBD::Oracle release
cycle more frequent and consistent -- I'm aiming for monthly milestones and...
we'll see how well it goes.

There's already a <a href="http://search.cpan.org/~pythian/DBD-Oracle-1.29_1/">developer version of the next
version </a> on CPAN. As soon as one lone but
<a href="https://rt.cpan.org/Ticket/Display.html?id=69350">nasty bug</a> is
squished, it'll be promoted to a bona fide release.

And for the near future? I plan for cleaning up the Makefile.PL, tidying
the 30-some bugs lingering in the RT queue, and corrupting lotsa smart minds
to do my bidding.

Wish me luck. :-)

