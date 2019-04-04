---
url: shuck-and-awe-10-hunting-for-perl
format: markdown
created: 2010-08-09
original: The Pythian Blog - http://www.pythian.com/news/15447/shuck-awe-10-hunting-for-perl/
tags:
    - Perl
    - Shuck & Awe
    - Perl 6
    - Rakudo
    - YAPC
    - gEdit
    - PerlTidy
    - Roles
    - CPANTS
    - optimization
    - parallel processing
    - XPath
    - XML
    - signatures
---

# Shuck & Awe #10: Hunting for Perl

<pre code="bash">
[yanick@enkidu shuck]$ perl -MFile::Find::Rule -MFile::Slurp=slurp \
    -E'say slurp $_ for File::Find::Rule->file->name("news")->in(".")'
</pre>


In a turn of events so monumental that it can only possibly be a sign that
Ragnarok is nigh upon us, an [early adopter implementation of Perl 6 has
been released](http://rakudo.org/announce/rakudo-star/2010.07). The 
[number](http://howcaniexplainthis.blogspot.com/2010/07/rakudo-star-is-here.html) 
[of](http://use.perl.org/~pmichaud/journal/40469)
[blog](http://use.perl.org/~Phred/journal/40466)
[entries](http://use.perl.org/~schwern/journal/40472)
[that](http://reneeb-perlblog.blogspot.com/2010/07/rakudo-star-perl-6-auf-parrot.html)
[it](http://www.modernperlbooks.com/mt/2010/07/how-about-a-shetland-ponie.html)
[generated](http://blogs.perl.org/users/ovid/2010/08/rakudo-is.html)
is, as one might expect, quite massive.  But the important is, the downloads
-- both for Unix and Windows -- are [available on Github](http://github.com/rakudo/star/downloads).
Don't lose any time! Go, download, compile, and get a taste of what the new
kid on the block has to offer.

Last week we also had the [2010 installment of
YAPC::EU](http://conferences.yapceurope.org/ye2010/),
which took place this year in Pisa. Again, [lotsa](http://blog.urth.org/2010/08/random-notes-from-yapceu-2010.html) 
[blog](http://logiclab.org/wordpress/2010/08/07/yapceurope-2010-pisa-italy-day-three/)
[coverage](http://perlgeek.de/blog-en/perl-6/my-first-yapc.html)
[of](http://brunorc.wordpress.com/2010/08/08/yapceu-2010-in-pisa-short-summary/)
[the](http://use.perl.org/~andy.sh/journal/40486?from=rss) 
[occasion](http://feedproxy.google.com/~r/PlanetPerl/~3/jFTeJmjX6ts/first-day-of-yapceu.html), including two
[blog](http://www.pythian.com/news/15343/larrys-keynote-at-yapceu-2010/) 
[entries](http://www.pythian.com/news/15377/yapceu-2010-day-two/) of our own special envoy, 
[John Scoles](http://www.pythian.com/news/author/johns).

Using gEdit to craft your code? [Job van Achterberg](http://blogs.perl.org/users/job_van_achterberg/)
shares with the world [his PerlTidy plugin for it](http://blogs.perl.org/users/job_van_achterberg/2010/08/perltidy-for-gedit.html).

Still not very clear about that new-fangled Role concept?
[Ovid](http://blogs.perl.org/users/ovid) wrote a very nice [language-agnostic
introduction to it](http://publius-ovidius.livejournal.com/314737.html).

The [Perl NOC](http://log.perl.org) reminds us that, with the arrival of the 
new CPAN Testers infrastructure, the old way of [submitting test reports via
email will go the way of the dodos on September 1st](http://log.perl.org/2010/08/cpan-testers-email-submission-interface-going-away-september-1st.html).

[Josh McAdams](http://www.effectiveperlprogramming.com) takes an isty-bitsy
Perl program, and shows us how [a few well-placed optimizations can turn it
into a speed demon](http://www.effectiveperlprogramming.com/blog/474).


Must be that time of the year. Both [Zbigniew
Lukasiak](http://perlalchemy.blogspot.com) and
[Pete Keen](http://bugsplat.info) worked on blog engines
(a [fork of RavLog](http://perlalchemy.blogspot.com/2010/08/ravlog-perl-blog-engine.html) and
[Bugsplat](http://bugsplat.info/2010-08-06-blog-generator-updates.html),
respectively). Funny thing, it seems that whatever blog nesting instinct
those guys felt I experienced as well, as I had a stab at my
own blog engine earlier last week (more details on that in a
not-so-future blog entry).

[dagolden](http://www.dagolden.com) shows us [how
to harness the power of multi-core processors with
Parallel::Interator](http://www.dagolden.com/index.php/935/parallel-map-with-paralleliterator/).

[jozef](http://use.perl.org/~jozef) brings our attention 
to [an XPath visualizer called
Xacobeo](http://use.perl.org/~jozef/journal/40476), a 
tool that is sure to come handy  for the XML wranglers
amongst us.

And, finally, [the Schwern](http://use.perl.org/~schwern) [announced
a new release of
Method::Signatures](http://use.perl.org/~schwern/journal/40474). This new
version is 5.12-friendly, faster than ever, and is quite
literally assured to bring back the `func` to your code.

<pre code="bash">
[yanick@enkidu shuck]$ perl -E'sleep 2 * 7 * 24 * 60 * 60 # see y'all in 2 weeks!'
</pre>
