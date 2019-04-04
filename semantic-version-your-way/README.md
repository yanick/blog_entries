---
title: Semantic Versioning Your Way
url: semantic-version-your-way
format: markdown
created: 2014-11-08
tags:
    - Perl
    - Dist::Zilla
---

I don't know if you remember, but a [wee while ago](blog:dist-zilla-semanticversion), I wrote
[Dist::Zilla::Plugin::NextVersion::Semantic](cpan:release/Dist-Zilla-Plugin-NextVersion-Semantic),
a dzil plugin that -- following the precepts of [semantic versioning][semver] -- increments the distribution's version in function of the
types of changes since the last release. And it's been a beloved part of my dzil
bundle ever since, but as it was only supporting the
two-dotted 'X.Y.Z' type of version, it was admittedly not engineered to cater
to everybody's taste.

That is, until now.

With its latest release, the plugin now accepts any format your heart might
desire via

    [NextVersion::Semantic]   
    format=%d.%3d.%3d

*Any format?* you ask? Well, maybe not Roman numerals or other weird weirdness yet, but any of the
usual format for sure:

    format=%d.%3d.%3d 
        PATCH LEVEL INCREASES: 0.0.998 -> 0.0.999 -> 0.1.0
        MINOR LEVEL INCREASES: 0.0.8 -> 0.1.0 -> 0.2.0
        MAJOR LEVEL INCREASES: 0.1.8 -> 1.0.0 -> 2.0.0

    format=%d.%02d%02d
        PATCH LEVEL INCREASES: 0.0098 -> 0.00099 -> 0.0100
        MINOR LEVEL INCREASES: 0.0008 -> 0.0100 -> 0.0200
        MAJOR LEVEL INCREASES: 0.0108 -> 1.0000 -> 2.0000

    format=%d.%05d
        MINOR LEVEL INCREASES: 0.99998 -> 0.99999 -> 1.00000
        MAJOR LEVEL INCREASES: 0.00108 -> 1.00000 -> 2.00000

Zero-padded, non-padded, two dots, one dot, no dots, it does it all.
And note that it means that you're not even tied to a 3 levels type of
versioning.  Define less, and the module will adjust in consequence -- changes that would
have triggered a patch-level increment will instead result in a minor-level
incremental (or a major-level incremental if only one level is defined).

Enjoy!

[semver]: http://semver.org/
