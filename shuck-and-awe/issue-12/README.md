---
url: shuck-and-awe-12
format: markdown
created: 9 Sep 2010
original: the Pythian Blog - http://www.pythian.com/news/16391/shuck-awe-12-hunting-for-perl/
tags:
    - Shuck & Awe
    - Perl
    - use.perl.org
    - Parcel
    - Perl 6
    - array context
    - cpans
    - CP2000AN
    - Catalyst
    - Const::Fast
---

# Shuck &amp; Awe #12: Hunting for Perl

<pre code="bash">
[yanick@enkidu shuck]$ perl -MO=Deparse news.pl
</pre>

Holy mackerel, [use.perl.org](http://use.perl.org) 
is [shutting down](http://use.perl.org/article.pl?sid=10/09/08/2053239)!
[Pudge](http://pudge.net/) is changing job and, as hist now-previous $workplace
was hosting the site, he is temporarily shutting down the site.  Breath easy,
though, the blog entries are not all going to disappear in a puff of smoke --
the site will be put in 'static' mode for the time being, and there is the 
possibility it will reappear somewhere else.
Love it or hate it, `use.perl.org` was one of the first and major Perl blog
hubs, and it served the community well during the last 10 years. I, for one,
can honestly say it'll be missed (and *yikes!*, I better make sure all my
old blog entries have been extracted and locally saved). 

Have a function that returns sometimes a scalar, sometimes an array? 
[The Schwern asks](http://twitter.com/schwern/status/23886308488): "why 
not use
[Parcels](http://github.com/schwern/List-Parcel/blob/master/lib/List/Parcel.pm)?"
He's taken the [Perl 6 Parcel data structure](http://perlcabal.org/syn/S08.html#Capture_or_Parcel)
and ported it to Perl 5.

[dagolden](http://www.dagolden.com) is fiddling with Perl's guts to have
the core array functions (`push`, `pop`, `shift` and friends) to [DWIM on 
array references](http://www.dagolden.com/index.php/1014/hacking-the-perl-core-to-push-and-pop-to-references).
His end-goal is to be able to do without the noisome array de-referencing in
situations like this

<pre code="perl">
my %foo;
push @{ $foo{bar} }, 'a'...'z';

print $foo{bar}[0];   # prints 'a'
</pre>

and instead directly do

<pre code="perl">
my %foo;
push $foo{bar}, 'a'...'z';

print $foo{bar}[0];   # also prints 'a'
</pre>

Nifty new rad feature, or yet another yard of rope to hang ourselves with? The
jury is still out (personally, I'm on the `oooh, shiny` side). 

Remember `cpans` from *Shuck & Awe*? Well, [Cornelius](http://c9s.blogspot.com)
reminds us that there's also a [Pure Perl version of the
tool](http://d.hatena.ne.jp/tokuhirom/20100901/1283303919),
and he goes on [writing a third version in Bash](http://c9s.blogspot.com/2010/09/cpans-bash-version.html), 
for the sake of completeness. 

[Dave Cantrell](http://www.cantrell.org.uk) managed to merge CPAN with a
TARDIS and [gives us
CP2000AN](http://www.cantrell.org.uk/david/journal/index.pl/id_cp2000an),
a view of all the distributions (with at least one successful test report)
that were on CPAN as of the beginning of 2000. And there's more. For like a
TARDIS moves in space as well in time, his `CP???AN` space-time distorting
machine also provides
us platform-centric views of CPAN. Only want to see distributions working on
Cygwin? There is [CPcygwinAN](http://cpmswin32an.barnyard.co.uk/).
Only want CPAN distributions working on Perl 5.8.8 on irix? 
There is [CP5.8.8-irixAN](http://cp5.8.8-irixan.barnyard.co.uk/). You want a
view of CPAN for Commodore 64? There is-- Darn. There's not a view for that
one yet.

No-one can stop the march of progress. [Perl 5.12.2](http://search.cpan.org/~jesse/perl-5.12.2/) is out.
No mind-blowing new feature this time, but a lot of 
[good healthy bug fixing](http://cpansearch.perl.org/src/JESSE/perl-5.12.2/pod/perl5122delta.pod).

[Andy Gorman](http://executionexception.wordpress.com) [introduces a new
Catalyst controller](http://executionexception.wordpress.com/2010/09/02/introducing-catalystcontrollerdirectorydispatch/) called
[Catalyst::Controller::DirectoryDispatch](cpan).  I'll let your imagine
run wild and try to come up with what functionality it performs (but I'll
nonetheless give you a hint: it's pretty much does what it says on the can).

First there was [constant](cpan). Then there was [Readonly](cpan).
Now [Leon Timmermans](http://blogs.perl.org/users/leon_timmermans/) [brings us
a new constant module](http://blogs.perl.org/users/leon_timmermans/2010/08/yet-another-readonly-module.html): 
[Const::Fast](cpan).  It's clean, it's simple, it's fast, and it doesn't
use XS or any other dark shenanigans. Clearly, a credible contender for the
conveted credentials of chief constant creator.

And lastly,  to leave this edition on a cheerful note, [chromatic](http://www.wgz.org/~chromatic)
takes time to stop, smell the flowers, and discuss 
[what's going right in Perl](http://www.modernperlbooks.com/mt/2010/09/whats-going-right-in-perl.html).


<pre code="bash">
[yanick@enkidu shuck]$ perl -E'sleep 2 * 7 * 24 * 60 * 60 # see y'all in 2 weeks!'
</pre>
