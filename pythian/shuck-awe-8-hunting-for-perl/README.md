---
url: shuck-awe-8-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/14459/shuck-awe-8-hunting-for-perl
created: 15 Jul 2010
tags:
    - CPAN
    - exception handling
    - gogoduck
    - iphone
    - logo
    - Moose
    - Perl6
    - search engine
    - smokers
    - the perl journal
    - Perl
    - Shuck & Awe
---

# Shuck &amp; Awe #8: Hunting for Perl

 <pre>[yanick@enkidu shuck]$ perl -MLWP::Simple -MNetscape::Bookmarks \
    -E&#39;getprint($_-&#62;href) for @{ Netscape::Bookmarks-&#62;new(pop)-&#62;{thingys} }&#39; news.html</pre>

<p><a href="http://blog-en.jochen.hayek.name/2010/07/interview-with-stevan-little-about.html">Jochen Hayek</a> makes hushing sounds, points at the radio, and motions us to listen to the <a href="http://perlcast.com/2010/07/12/stevan-little-on-moose/">Perlcast of Stevan Little on Moose</a>.</p>

<p>Inspired, but not completely satisfied with <a href="http://perl6.org/">Camelia, the Perl 6 mascot</a>, <a href="http://blog.kraih.com">Sebastian Riedel</a> came up with <a href="http://blog.kraih.com/a-logo-for-perl">a new set of butterfly logos for the Perl 5/6 family</a>. Very purty, methinks, very purty indeed.</p>

<p><a href="http://use.perl.org/~schwern/">Schwern</a> has implemented method and function signatures for the maverick <a href="http://search.cpan.org/dist/perl5i/">Perl5i</a>. The keyword for methods is easy to come up with, but for subroutine, what should it be, <a href="http://use.perl.org/~schwern/journal/40444">‘func’ or ‘def’</a>?</p>

<p>Need your module documentation within reach of your eyeballs whenever, wherever you are? Then you are a hopeless techno-junkie. Still, rejoice, for there’s an app for that. Yes, <a href="http://blogs.perl.org/users/olaf_alders">Olaf Alders</a> and a friend came up with <a href="http://blogs.perl.org/users/olaf_alders/2010/07/icpan-cpan-on-your-iphone.html">iCPAN for the iPhone</a>. Now, if they could only come up with a BlackBerry port…</p>

<p><em>It’s aaaaaah-live</em>! CPAN Testers 2.0 is up and running. And <a href="http://www.dagolden.com">David Golden</a> reminds us that the days of its first incarnation are counted. If you are interested to send test reports for your platform, <a href="http://www.dagolden.com/index.php/889/how-to-join-the-cpan-testers-2-0-public-beta/">consider join the Tester Corp</a>.</p>

<p><a href="http://duckduckgo.com">DuckDuckGo</a> is a new player in the search engine arena. It’s also written in Perl. In his blog, <a href="http://www.gabrielweinberg.com">Gabriel Weingberg</a> <a href="http://www.gabrielweinberg.com/blog/2009/03/duck-duck-go-architecture.html">discusses its architecture</a>.</p>

<p>In the department of small-yet-fun tricks, <a href="http://blogs.perl.org/users/smash">smash</a> shows us how to find out <a href="http://blogs.perl.org/users/smash/2010/07/one-liner-history-command-counter.html">your top 5 cli commands</a>. (hmmm… mine involve Perl, Catalyst, Git, <code>dzil</code> and good ol’ <code>ls</code>)</p>

<p><a href="http://blog.woobling.org">Yuval Kogman</a> is scheming wonderful, terrible things to get Perl’s exceptions to <a href="http://blog.woobling.org/2010/07/are-we-ready-to-ditch-string-errors.html">break away from strings and embrace objects instead</a>.</p>

<p>A useful tip for module maintainers from David Golden: <a href="http://www.dagolden.com/index.php/875/downloading-rt-patches-from-the-command-line">how to download RT patches from the command line</a>.</p>

<p>And, finally, <a href="http://blogs.perl.org/users/brian_d_foy">brian d foy</a> is <a href="http://blogs.perl.org/users/brian_d_foy/2010/07/im-looking-for-issues-of-the-perl-journal.html">looking for hard-copies of The Perl Journal</a>. If you have some sitting in a box somewhere, consider giving him a poke.</p>

<pre>[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see y&#39;all in 2 weeks!&#39;</pre> 
