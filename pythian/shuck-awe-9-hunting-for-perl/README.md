---
url: shuck-awe-9-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/15087/shuck-awe-9-hunting-for-perl
created: 28 Jul 2010
tags:
    - Perl
    - Shuck & Awe
    - administration tools
    - Catalyst
    - DBIx::Class
    - deployment
    - Dist::Zilla. Perl 5.12
    - Git
    - oscon
    - roles
    - sdl
    - Zelda
---

# Shuck &amp; Awe #9: Hunting for Perl
<pre>
[yanick@enkidu shuck]$ perl -MGit::Wrapper \
    -E&#39;say for Git::Wrapper-&#62;new(&#34;.&#34;)-&#62;show( &#34;master:shuck-and-awe-9&#34; )&#39;
</pre>

<p>First this week we have <a href="http://genehack.org">John Anderson</a> filling us up on the <a href="http://genehack.org/2010/07/the_dph_is_dead/">Perl high drama of OSCON</a> of earlier this week. In a nutshell the organizers provided, as it’s the tradition, ribbons to the attendees, and the Perl Mongers in the crowd got one reading <em>Desperate Perl Hacker</em>. The epithet, coined in <a href="http://www.xml.com/pub/a/w3j/s3.perl.html">an XML article written in 1997</a>, was meant in good fun, but was received with a distinct lack of glee by the Perl hackers. Which is no surprise, considering how mongers already have to fight tooth and nail to dispel the heavy baggage of preconceptions that our language accumulated throughout the years. Quite a few blog entries sprouted to discuss the whole hooplah, with <a href="http://www.bofh.org.uk">Piers Cawley</a>’s being <a href="http://www.bofh.org.uk/2010/07/25/a-tale-of-two-languages">one of the most eloquent</a>, explaining that, yes Virginia, Perl can, and is, often used at the 11th hour to save someone’s bacon and, consequently, has instances of code that are less than perfectly pretty. But, it’s also much more than an emergency fire extinguisher and and has flip side that consists of a strong, solid and modern ecosystem that can, and is, definitively used for bigger projects.</p>

<p>Buuut enough about that. Let’s return to our regular parade of technological goodies, shall we?</p>

<p>Perl 5.12 will issue some deprecation warnings, even if the <code>warnings</code> pragma is not enabled. brian d foy <a href="http://www.effectiveperlprogramming.com/blog/463">walks us through them</a> and dares us to turn them off. But before we do, he asks us to ask ourselves a very simple question. Namely, as punks, do we feel lucky? Do we?</p>

<p><a href="http://www.illusori.co.uk">Sam Graham</a> joins the angst-filled crowd and, without doubt starring at the empty sockets of a grinning skull, asks himself <a href="http://www.illusori.co.uk/perl/2010/07/24/to_dist_zilla_or_not_to_dist_zilla.html">To Dist::Zilla, or not to Dist::Zilla</a>.</p>

<p>DBIx::Class users, prepare to squeal in delight. <a href="http://blog.afoolishmanifesto.com">fREW</a> opened a can of delicious frosting and <a href="http://blog.afoolishmanifesto.com/archives/1390">came up with DBIx::Class::Candy</a>. </p>

<p><a href="http://ali.as">Adam Kennedy</a> gives us a glimpse of how his team deals with the <a href="http://use.perl.org/~Alias/journal/40453">deployment of massive Perl applications</a>. <em>Massive, really</em>, you ask? 250,000 lines of Perl, spread over 750 modules, managing 100,000 physical users, with a turn over of about a billion dollars. So, yeah, <strong>massive</strong>, I say. </p>

<p><a href="http://hanekomu.at">Hanemoku</a> presents <a href="http://hanekomu.at/blog/cpan_gems/20100716-1556-modern_perl_administration_tools.html">a few modern Perl administration tools</a>. Some of them you might have seen in previous Shuck and Awe issues, some are new, all are good to know and have in your toolbox.</p>

<p><a href="http://yapgh.blogspot.com">Kartak</a> is working on SDL gaming goodness. As a sneak preview of things to come, he shows us a <a href="http://yapgh.blogspot.com/2010/07/huge-world-maps-in-less-then-100-lines.html">Zelda map walker</a>. (<em>Oooh, the memories…</em>) </p>

<p>Our very own <a href="http://deanpearce.net/">Dean</a> is putting some popular web frameworks to the test and see how easy/fast it is to write a blog application using them. <a href="http://deanpearce.net/get-a-reaction-with-catalyst/">His first contestant? Catalyst.</a> </p>

<p>Using DBIx::Class, and your table has some horrendously huge columns that you don’t necessarily want to retrieve each time you query a row? <a href="http://blogs.perl.org/users/ovid">Ovid</a> had that problem too, and shows us <a href="http://blogs.perl.org/users/ovid/2010/07/lazy-database-columns-and-virtual-vertical-partitioning.html">how he deals with it</a>. </p>

<p>Roles in Perl? They’re awesome. Chris Prather <a href="http://perlbuzz.com/2010/07/why-roles-in-perl-are-awesome.html">tells you why</a>.</p>

<p>Git is a developer’s best friend — maybe rough at the edges, maybe grumpy, but always there to make your life easier. However, a lot of projects / companies still use Subversion for a variety of reasons (politics, legacy, not having realized we have stepped into the 21st century yet, etc.). Not to fear, <a href="http://blog.afoolishmanifesto.com/archives/1386">as fREW discovered recently</a> <code>git-svn</code> is there to seamlessly bridge the svn mothership with your very own private satellite repository. </p>

<pre><code>[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see y&#39;all in 2 weeks!&#39;
</code></pre> 
