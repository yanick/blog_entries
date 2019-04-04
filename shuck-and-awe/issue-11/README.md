---
url: shuck-and-awe-11
format: markdown
created: 2010-08-27
original: the Pythian Blog - http://www.pythian.com/news/15947/shuck-awe-11-hunting-for-perl/
tags:
    - Shuck & Awe
    - Perl
    - cpans
    - YAPC
    - Vim
    - Moose
    - Perl Fundation
    - debugger
---

# Shuck &amp; Awe #11: Hunting for Perl

<pre code="bash">
[yanick@enkidu shuck]$ perl -V:news
</pre>

Do you regularly scuba dive in a motley sea of other peeps' codebase, trying
to bring on surgical changes without doing too much collateral b0rking on the
code formatting? If so, [Steffen Mueller](http://blogs.perl.org/users/steffen_mueller)
has a nifty trick to share with you. Using [Text::FindIndent](cpan), he
shows [how to configure Vim such that it can magically adapts to any
indentation policy](http://blogs.perl.org/users/steffen_mueller/2010/08/tiny-vim-convenience-hack.html).

Talking of Vim, [Andy Lester](http://theworkinggeek.com/) 
let  us know that [Vim 7.3 is
out](http://perlbuzz.com/2010/08/vim-73-supports-perl-6.html),
with a bunch of upgrade to its Perl-related support files (and that
includes brand-new support for Perl 6).

CPAN is great, CPAN is awesome. But, as we all know, the leviathanesque amount
of distributions it contains is sometime daunting. Which module should I use
to perform *$random_task*? [Jesse Thompson](http://blogs.perl.org/users/jesse_thompson)
proposes to [look at how many other modules are dependent on a
distribution](http://blogs.perl.org/users/jesse_thompson/2010/08/cpan-search-dependents.html)
as a metric, and provides a [greasemonkey script](http://userscripts.org/scripts/show/84296) 
to retrieve that information straight on the CPAN search page.

This year we've seen the rise of a lot of über-cool <i>cpan*</i> and
<i>perl*</i> utilities. The latest, announced by
[Cornelius](http://c9s.blogspot.com), is [a little speed-demon called
`cpansearch`](http://c9s.blogspot.com/2010/08/cpansearch-cpans_23.html).
Written in C (which gives it mongoose-like response time) it is a module
searching tool. Already cool on its own


<pre code="bash">
$ time cpans XPath | head
Source list from: http://cpan.nctu.edu.tw/modules/02packages.details.txt.gz
Apache::AxKit::Language::XPathScript     - 0.05 (M/MS/MSERGEANT/AxKit-1.6.2.tar.gz)
Apache::XPointer::XPath                  - 1.1 (A/AS/ASCOPE/Apache-XPointer-1.1.tar.gz)
AxKit2::Transformer::XPathScript         - 0 (M/MS/MSERGEANT/AxKit2-1.1.tar.gz)
B::XPath                                 - 0.01 (C/CH/CHROMATIC/B-XPath-0.01.tar.gz)
Cindy::XPathContext                      - 0 (J/JZ/JZOBEL/Cindy-0.15.tar.gz)
Class::XPath                             - 1.4 (S/SA/SAMTREGAR/Class-XPath-1.4.tar.gz)
Config::XPath                            - 0.16 (P/PE/PEVANS/Config-XPath-0.16.tar.gz)
Config::XPath::Reloadable                - 0.16 (P/PE/PEVANS/Config-XPath-0.16.tar.gz)
Email::MIME::XPath                       - 0.005 (H/HD/HDP/Email-MIME-XPath-0.005.tar.gz)

real    0m0.168s
user    0m0.016s
sys     0m0.020s
</pre>

it can yet achieve higher levels of radness if combined with other Perl tools
like `cpanm`:

<pre code="bash">
# install all that is tiny
$ cpans -n Tiny | cpanm
</pre>

YAPC::NA and YAPC::Europe came and went, but [Karen Pauley](http://martian.org/karen)
reminds us that there's still [YAPC::Asia happening in Tokyo in
October](http://martian.org/karen/2010/08/23/yapcasia-2010/), and that the
tickets are now on sale.

What? Didn't attend any YAPC::* yet this year? Oh well, at least [Matt S
Trout](http://twitter.com/shadowcat_mst/status/21935887405) points us 
where we can [download](http://conferences.yapceurope.org/ye2010/news/632) 
[videos](http://www.presentingperl.org/ye2010/) of some of their talks.

Have you noticed that you can't use the 5.10 features (like the smart
match, `say`, `given / when`) under the Perl debugger? 
[Pablo Marin-Garcia](http://pablomarin-garcia.blogspot.com)
did, and [dug to find out why](http://pablomarin-garcia.blogspot.com/2010/08/perl-debugger-and-perl-510-features.html).
Also check the comments for a dirty way to force the debugger into a more
modern attitude.

[Moose](cpan) is a mighty beast, but it's not the fastest ungulate you'll
ever meet. But thanks to [Dave Rolsky](http://blog.urth.org/), it now [compiles
10% faster than it used to](http://blog.moose.perl.org/2010/08/moose-110-and-classmop-105-now-compiling-10-faster.html).
w00t!

[Alberto Simões](http://null.perl-hackers.net/) reports that the [Perl
Foundation accepted grants for 2010Q3 are in](http://news.perlfoundation.org/2010/08/accepted-grants-for-2010q3.html).
From the look of it, lots of documentation -- game development with SDL,
Perlbal, Perl 6, Parrot -- is coming our way.

Does anyone remember Mazinger Z? Each time we thought that giant robot
achieved the peek of ultimateness, it would interface with a new
ship/contraption/coffee machine and become even awesomer. Moose, with its
`MooseX` cohorts, is a little bit like that. But with antlers. [Florian
Ragwitz](http://planet-de.debian.net/) shows us how the raw power of 
parameterized traits given by [MooseX::Role::Parameterized](cpan)
can now be harnessed by [MooseX::Declare](cpan).


<pre code="perl">
use MooseX::Declare;
use 5.10.0;

role Gizmo ( Str :$codename ) {

    has 'upgraded' => ( is => 'rw' );

    my %gizmo_ability = (
        'wingy_thingy'  => 'fly like a butterfly',
        'smash_o_tron'  => 'squish things',
        'expresso_core' => 'make darn good coffee',
    );

    method "summon_$codename" {
        say "Giant robot summons its $codename";
        $self->upgraded(1);
    }

    method unleash_power {
        say $self->upgraded 
            ? "Giant robot can now $gizmo_ability{ $codename }" 
            : "No gizmo? No super-power for you"
            ;
    }
}

class GiantRobot::Omega {
    with Gizmo => { codename => 'expresso_core' };
}

my $robot = GiantRobot::Omega->new;

$robot->unleash_power;         # No gizmo? No super-power for you

$robot->summon_expresso_core;  # expresso core, to me!

$robot->unleash_power;         # *mouahaha*
</pre>

<pre code="bash">
[yanick@enkidu shuck]$ perl -E'sleep 2 * 7 * 24 * 60 * 60 # see y'all in 2 weeks!'
</pre>
