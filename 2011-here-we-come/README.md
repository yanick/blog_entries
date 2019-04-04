---
created: 2011-01-04
url: 2011-here-we-come
tags:
    - Perl
    - Catalyst::Plugin::VersionedURI
    - Dist::Zilla::PluginBundle::YANICK
    - Dancer::Template::Mason
    - XML::XSS
    - resolutions
    - todo
    - Galuga
---

# My Perl Worklist for 2011

The Holiday Season was a very Perlish one for me. With two
weeks' worth of vacation time, and my mother-in-law visiting,
I had plenty of time to sit down, leasurely sip some hot cocoa and hack
my merry little heart away. Net result: four new/updated modules
([Catalyst::Plugin::VersionedURI](cpan),
[Dist::Zilla::PluginBundle::YANICK](cpan),
[Dancer::Template::Mason](cpan) and
[XML::XSS](cpan)) and <strike>six</strike> seven
blog entries. And that's not counting the
many acts of random patching, the secret experiments and other such pleasant
yak shaving. All Very Good Stuff that makes me Quite Happy.

And now that we are entering 2011, I thought I could stop for a few seconds
to join the [Todo meme](http://blogs.perl.org/users/brian_d_foy/2010/11/my-programming-related-todo-list.html)
and list what I hope be able to work on for the next little while. So...
Here's what one could expect from little me in the new year, programming-wise:

* Attend a Perl Conference. Because methinks I'm way overdue for one of those.
    Perhaps [Asheville](http://www.yapc2011.us/yn2011/)?

* Dust off [cpanvote](http://babyl.dyndns.org/techblog/entry/cpanvote-a-perl-mini-project).  I've been talking with the [cpan-api](https://github.com/CPAN-API) folks,
    and there is interest to merge the `cpanvote` functionality with the
    nascent `CPAN-API` project.  Very exciting. As we speak, I'm working on a
    <cpan>Dancer</cpan> version of `cpanvote` that should be ready in a few
    days.

* Actually begin to use my [Smolder/TAP monitoring
    system](http://babyl.dyndns.org/techblog/entry/system-monitoring-on-the-cheap)
    in earnest. (I'm great at coming up with great tricks, but terrible
    at actually using them)

* Spare some time to give <cpan>CGI.pm</cpan> some love. Strangely, I've found
    myself part of the unofficial maintenance crew for that grand-daddy of a
    module. As I'm not really using it, I've not paid enough attention to its
    bug queue lately -- I should try to change that.

* Release a new <cpan>Pod::Manual</cpan> that actually works. And by
    "actually work", I mean "take all the modules of the main
    [Moose](cpan) distribution and turn it into a magnificent pdf".

* Clean up <cpan>XML:XSS</cpan>'s documentation and turn it into something somebody else would actually want to use.


* Create a <cpan>Dist::Zilla</cpan> plugin that automatically close RT tickets
    mentioned in the `Changelog`.

*  In the same vein, hack a script tha take my RT tickets and create
    [Hiveminder](http://hiveminder.com) items out of them.

* Tinker on [Galuga](http://github.com/yanick/galuga). It's already quite
    serviceable, but there's still a lot of prettification that can be done.
    And widgets that could be plastered all over the place. And a mobile mode.
    And a automatic ebook converter.

* Continue to hack on the [space game](http://babyl.dyndns.org/techblog/entry/perl-in-space).
    Just for the heck of it, and to play with SVG and Raphaël.

* Give <cpan>NetPacket</cpan> a Moose-based little brother. As `NetPacket`
    itself is often used in small scripts where speed matter, I can't really
    Moosify it, but creating a new sister dist named `Net::Datagram` would
    nicely provide an alternative to the venerable `NetPacket` dinosaur.

* Write `Mouse d'`, a web app that is sure to make me insanely rich and famous.

* Give <cpan>Games::Perlwar</cpan> a Dancer front-end.


And, of course, lots of other stuff that is sure to pop here and there, as
other stuff is wont to do.
