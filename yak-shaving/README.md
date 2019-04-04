---
created: 2012-02-05
tags:
    - Perl
    - Yak shaving
    - Perl::Achievements
    - pm_changelog
---

# Faster, hairy yak, shave, SHAVE! 

As [reported
yesterday](http://babyl.dyndns.org/techblog/entry/dist-zilla-plugin-coalescepod),
this week-end's activities could be summarized as me going to town on a yak
herd with a lawnmower. And although the rest of Saturday and this morning
haven't been as fast and furious as Saturday morning, there's a few more
things to report:

The [wish of
Genehack](https://twitter.com/#!/genehack/status/165252271981080576) has been
answered,
and a new version of [Perl::Achievements](cpan) is out, including the
sub-command '`report`', which spits out an html version of the user's current
achievements (the GitHub page of the project is now a [sample of the output](http://yanick.github.com/Perl-Achievements/)). 

I already mentioned that one of the steps in churning that out was to
release [Template::Caribou](cpan) to CPAN (actually, I just realized I
forgot to do that. *oops* ... Mistake corrected, now). Something additional I
should point out is that its tests are leveraging the 
awesomeness of [Test::Routine](cpan). As `Template::Caribou` itself is a
role, everything mashes together rather niftily in the [test
file](https://github.com/yanick/Template-Caribou/blob/master/t/basic.t). I
like, I like a lot.

And then, yesterday night, Gabor gently poked me about the fact that Galuga's
feed and the [IronMan](http://ironman.enlightenedperl.org/)'s aggregator don't seem to understand each other very
well.  for some mysterious reason, the aggregator reposts the last few entries
each time I write something new. Very aggravating, moreover considering that
the source feed itself seems sane.  Oh well, in an effort to fix that, I've
switched the RSS-generating engine of Galuga from
[XML::Atom::SimpleFeed](cpan) to [XML::Feed](cpan). ... and promptly
found out that old versions of `XML::Atom` plays havok with the output of
`XML::Feed`.  

No problem, I upgraded and filed a [bug report](https://rt.cpan.org/Ticket/Display.html?id=74703).
And then I wondered, "isn't there a cli tool out there to fetch the changelog of a
distribution from [MetaCPAN](https://metacpan.org)?". I searched a little bit
but without success. So I [rewrote
it](https://github.com/yanick/environment/blob/master/bin/pm_changelog).  My
version of the tool peek on MetaCPAN for a file named `Changes` or `Changelog`
or `CHANGES`, try to load it via [CPAN::Changes](cpan) and show the part
of the changelog above and beyond the version currently installed (unless the
`--all` option is passed).  If the changelog doesn't pass muster with
`CPAN::Changes` (tsk, tsk), it's just dumped verbatim.  

```bash
$ pm_changelog XML::LibXML
installed version: 1.88
latest version: 1.90

1.89 2011-12-24T09:46:26Z
- Apply a patch with spelling fixes by Kevin Lyda : -
https://rt.cpan.org/Public/Bug/Display.html?id=71403 - Thanks to Kevin.
- Apply a pull request by ElDiablo with the implementation of
- lib/XML/LibXML/Devel.pm .
- Adjust the Win32 Build Instructions in the README file. - Thanks to
Christopher J. Madsen.


1.90 2012-01-08T20:57:58Z
- Pull a commit from Aaron Crange to fix compilation bugs in Devel.xs: -
local variable declarations must be in the PREINIT section, not `CODE`,
at least for some compiler/OS combinations. - Thanks, Aaron!
```

So, yeah... how's *your* week-end going?

