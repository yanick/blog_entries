---
created: 2012-03-19
tags:
    - Perl
    - Dist::Zilla
---

# Cambrian Explosion (Dist::Zilla Plugins Galore)

Tonight, I finally had a little time to spit out a few of the [Dist::Zilla](cpan)
plugins I had in the wing for the last couples of months...

## Dist::Zilla::Plugin::NextVersion::Semantic

The pièce de résistance is
[Dist::Zilla::Plugin::NextVersion::Semantic](cpan) which I had promised
to Mike Doherty a long time ago.  In  a nutshell, the plugin examines the
changes of the upcoming release and increases the version according to the
rules of [semantic versioning](http://semver.org/).

The plugin itself is nothing too fancy, but since the incrementation has
nothing to do with how we retrieve the previous version for the distribution,
I created a new role,
[Dist::Zilla::Role::YANICK::PreviousVersionProvider](https://metacpan.org/module/Dist::Zilla::Role::YANICK::PreviousVersionProvider). The
*YANICK* is there as not to encroach on the official role namespace. I intend
to poke rjbs and see where he would prefer such ad-hoc roles to live, and am
likely to rename the role in consequence.  In all cases, with the distribution
comes
[Dist::Zilla::PreviousVersion::Changelog](https://metacpan.org/module/Dist::Zilla::PreviousVersion::Changelog), which consumes
that role and grab the previous version straight out of the changelog.

Also, although I personally use a two-dotted type of versioning, I know that it's...
let's just say not well-liked everywhere. In consequence, everybody will be
happy to know that the plugin can also generate a *x.yyyzzz* type of version
as well.

## Dist::Zilla::Plugin::Covenant

Remember [that discussion](http://www.nntp.perl.org/group/perl.module-authors/2011/11/msg9498.html)?
I had drafted a `Dist::Zilla` plugin at the time, and now with a little bit of
dusting off, here it is: [Dist::Zilla::Plugin::Covenant](cpan).

## Dist::Zilla::Plugin::SchwartzRatio

And just because I was on a roll, I churned a very quick
[Dist::Zilla::Plugin::SchwartzRatio](cpan) which, after a successful
release, looks how many old versions of the distro are lying around so that
we can have an inkling of when a good Spring cleaning might be in order. The
output of the plugin looks like

```bash
...
[@YANICK/Twitter] Released Dist-Zilla-PluginBundle-YANICK-0.9.0 http://tinyurl.com/6umco6e
--> Working on .
Configuring Dist-Zilla-PluginBundle-YANICK-0.9.0 ... OK
Building and testing Dist-Zilla-PluginBundle-YANICK-0.9.0 ... OK
Successfully installed Dist-Zilla-PluginBundle-YANICK-0.9.0
1 distribution installed
[@YANICK/InstallRelease] Install OK
[@YANICK/SchwartzRatio] 13 old releases are lingering on CPAN
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.7.0
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.6.0, 04 Feb 2012
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.5.1, 03 Feb 2012
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.5.0, 03 Dec 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.4.3, 14 Nov 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.4.2, 25 Sep 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.4.1, 29 Aug 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.4.0, 20 Jun 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.3.0, 17 Apr 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.2.1, 10 Apr 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.2.0, 10 Apr 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.1.0, 02 Jan 2011
[@YANICK/SchwartzRatio]         Dist-Zilla-PluginBundle-YANICK-0.0.1, 21 Dec 2010
```


So... enjoy! Me, I have to go and watch transtemporal
criminals fight comic shop owning PhDs while I do an amigurumi hair
transplant...
