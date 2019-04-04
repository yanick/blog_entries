---
title: Greasemonkeying dependencies
format: html
created: 28 Jan 2008
original: use.perl.org - http://use.perl.org/~Yanick/journal/35507
tags:
    - Greasemonkeying
    - CPANdeps
    - CPAN
---

<p>Escalation wars... you just have to love'em.</p><p>First, David
came up with the über-cool <a href="http://cpandeps.cantrell.org.uk/" rel="nofollow">
CPAN deps</a> page.</p><p>Then <a href="http://use.perl.org/~AndyArmstrong/journal/" rel="nofollow">Andy</a>
comes up with a <a href="http://use.perl.org/article.pl?sid=07/12/15/1931244" rel="nofollow">nifty Greasemonkey script </a>
to add it to the CPAN distributions main pages. </p><p>Then I add a small patch to the script to retrieve
some information from the Deps page.</p><p>Then David creates an xml interface to CPAN deps, opening the
door wide open for Web 2.0 goodiness.</p><p>Then (and this is where we are right now) I hack together a new <a href="http://userscripts.org/scripts/show/21779" rel="nofollow">CPAN_Dependencies</a> monkeyscript
to take advantage of said xml interface.</p><p>This, of course, is nowhere near the end of the story.
My new script only scratches the surface of what can be done with the
information contained in the xml. As soon as I have some tuits,
I'll probably add a way to toggle between showing only the first-level
dependencies and all dependencies, and have dependencies color-coded
by degree of b0rkage, and whatever bell or whistle I can think of in
the meantime.</p>
