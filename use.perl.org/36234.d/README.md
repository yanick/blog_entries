---
title: CPAN/Ohloh mashup
url: cpan-ohloh-mashup
format: html
created: 23 Apr 2008
original: use.perl.org - http://use.perl.org/~Yanick/journal/36234
tags:
    - Perl
    - Ohloh
    - GreaseMonkey
---

<p>
Now that I've registered my Perl modules on
<a href="http://www.ohloh.net/" rel="nofollow">Ohloh</a>,
I thought it'd be fun to make things bilateral
and have one of the <a href="http://www.ohloh.net/projects/test-pod-snippets/widgets" rel="nofollow">Ohloh widgets</a>
displayed on the
modules' CPAN page.  So I mustered my <a href="http://www.greasespot.net/" rel="nofollow">Grease</a>-Fu, and
hacked
<a href="http://userscripts.org/scripts/show/25525" rel="nofollow">a little something</a>.
</p><p>
With that little script installed, if a module dist is registered
on Ohloh [*], its widget will appear on the right side of
the CPAN page right below the gravatar picture.
</p><p>
For sample modules, have a gander at
<a href="http://search.cpan.org/~yanick/Test-Pod-Snippets-0.02/" rel="nofollow">
Test::Pod::Snippet</a> or
<a href="http://search.cpan.org/~yanick/XML-XPathScript" rel="nofollow">XML::XPathScript</a>.
</p><p>
<b>[*]</b> The project must also be configured to have a
<a href="http://www.ohloh.net/announcements/human_project_urls" rel="nofollow">name url</a>
corresponding to module's name in lowercase and with all '::'
substitued by '-' (e.g., 'Test::Pod::Snippets' => 'test-pod-snippets').
</p>
