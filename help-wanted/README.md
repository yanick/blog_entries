---
title: Help Wanted - A Proposal
url: help-wanted
format: markdown
created: 26 Jun 2012
tags:
    - Perl
    - metacpan
---

It really doesn't take me a lot to go meta on stuff...

Today I got poked about a long lasting bug on [WWW::Ohloh::API](cpan),
which prompted me to release a new interim version to prevent its userbase
from rioting before I can finish the port of the whole thing to
[Moose](cpan) -- port that has been in the wing for the last, oh, 4
years. "Four years?", you say. "Alas, yup," I meekly reply. You know the
regular excuses: so many distributions, so little time, and I am not really
using it myself so the itch factor is not really there, etc. And I thought it 
could be time to push this particular distribution in the arms of 
somebody who could take better care of it than I (but only after I'm done with
Moosifying it, though. That is too fun to pass on)

Which reminded me of the recurrent CPAN problem of module adoption. The
last time the issue resurfaced, which was a few months ago, the
[discussion][thread] was
centered on the related problem of authors dropping off the map. At the end, a
proposal of a voluntary pledge of "if I kick the bucket, peeps can take over
my CPAN modules" was crafted and implemented at least by
[Dist::Zilla::Plugin::Covenant](cpan).

But there is still a need for something to help authors who either want to pass the torch of 
maintainership to somebody else, or just would like some help with their
module. Something simple, and yet that would be easily visible by the CPAN
community.  So I began to think (hey, I saw that shiver!) and said to myself
*"what if..."*

What if we added a new field in the `META.json` -- let's call it
`x_help_wanted` --  that would contains all the 
different types of help a module maintainer could require? Positions like 
*maintainer*, *co-maintainer*, *coder*, *translator*, *documentation* and
*tester*.  We could even have a [Dist::Zilla](cpan) plugin to populate
that field for us. Something like, say, [this][dzphw].

And what if [MetaCPAN](https://metacpan.org) would display that information
on the release page?  With `MetaCPAN` being so nifty, one would think that 
only a wee bit of code, something like [this][withhelp], would suddenly make
the desired information pop out of nowhere:

<div align="center"><img SRC="__ENTRY_DIR__/help_wanted.png" alt="screenshot"
/></div>

Of course, one should probably flesh out the info on the release page with
descriptions of what each of those positions entail, and who/how to contact
the module head honchos. But that's all details that can be piled on top of 
the prototype.

So, yeah, what if. What if we had those pieces available. Do you think
it would help us?


[thread]: http://www.nntp.perl.org/group/perl.module-authors/2011/11/msg9500.html
[dzphw]: https://github.com/yanick/Dist-Zilla-Plugin-HelpWanted
[withhelp]: https://github.com/yanick/metacpan-web/commit/f4f5ddf8e4d56301906faeca66a5272887252a6f
