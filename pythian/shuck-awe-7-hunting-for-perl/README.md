---
url: shuck-awe-7-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/13913/shuck-awe-7-hunting-for-perl
created: 29 Jun 2010
tags:
    - blogger
    - dbix-class
    - flip-flop operator
    - grep operator
    - java
    - kiokudb
    - Perl6
    - The Perl Foundation
    - web application performance
    - Shuck & Awe
---

# Shuck &amp; Awe #7: Hunting for Perl

 <pre><code>[yanick@enkidu shuck]$ perl -MXML::LibXML \
    -E&#39;say $_-&#62;toString for \
        XML::LibXML-&#62;load_xml( location =&#62; &#34;news.xml&#34;)\
                   -&#62;findnodes( q{//news[@lang=&#34;perl&#34;]} )&#39;
</code></pre>

<p>No one is safe from the TPF Inquisition. <a href="http://null.perl-hackers.net/">Alberto Simões</a> <a href="http://news.perlfoundation.org/2010/06/testbuilder-2-updates.html">cornered Michael Schwern at YAPC</a> and exacted a confession about the state of Test::Builder 2. No doubt threatened by the horrid torments that only torture by the comfy chair can provide, the Schwern <a href="http://use.perl.org/~schwern/journal/40421">spilled the beans</a>.</p>

<p>For the readers who aren’t BFF with Perl’s <code>grep</code> function yet, <a href="http://blogs.perl.org/users/smash/">smash</a> provides <a href="http://blogs.perl.org/users/smash/2010/06/grep-is-your-friend.html">a little example how this function can help making your code shorter, faster, and most important, easier to read</a>.</p>

<p><a href="http://perlgeek.de/blog-en/">Moritz Lenz</a> announces the Perl 6 challenge of this week: <a href="http://perlgeek.de/blog-en/perl-6/contribute-now-argfiles.html">implementing $*ARGFILES</a>. He also announces the winners of the previous weeks, which have been <a href="http://perlgeek.de/blog-en/perl-6/contribute-now-lottery.html">selected by a Perl 6 script</a>.</p>

<p>The <a href="http://use.perl.org/~chromatic/journal/40423">first draft of the Modern Perl Book is available for reviews</a>, <a href="http://use.perl.org/~chromatic/">chromatic</a> sayz. Veterans, now is the time to do your part and review a section or two.</p>

<p><a href="http://search.cpan.org/dist/KiokuDB/">KiokuDB</a> is nifty. <a href="http://search.cpan.org/dist/DBIx-Class">DBIx::Class</a> is awesome. <a href="http://nothingmuch.woobling.org/">Yuval</a> has worked his magic again to allow <a href="http://blog.woobling.org/2010/03/kiokudb-for-dbic-users.html">the use of the former on top of the latter</a>. Would the result be niftwesome or awesifty? You be the judge.</p>

<p><a href="http://www.effectiveperlprogramming.com/">brian d foy</a> reminds us that <a href="http://www.effectiveperlprogramming.com/blog/314">the flip-flop operator uses a global state</a>, and what it means in term of potential gotchas.</p>

<p><a href="http://blogs.perl.org/users/ovid/">Ovid</a> shares <a href="http://blogs.perl.org/users/ovid/2010/06/getting-married-and-posting-to-blogger.html">how to post to Blogger</a>. Oh yeah, and he’s now married and has a child process in the compilation stage. w00t! </p>

<p><a href="http://www.kiffingish.com">Kiffin Gish</a> found out the hard way that you only ever truly realize how much you need something only <a href="http://www.kiffingish.com/2010/06/dont-run-this-command.html">after it’s gone</a>. Oops.</p>

<p>In the “building bridges” department, Tim Bunce tackles the equivalent of a Gibraltar Strait overpass and started a project on GitHub that <a href="http://github.com/timbunce/java2perl6">takes Java classes and translates them into their Perl 6 equivalents</a>. </p>

<p><a href="http://blog.twoshortplanks.com">Mark Fowler</a> discusses the art of <a href="http://blog.twoshortplanks.com/2010/06/26/measuring/">measuring the performance of web applications</a> and gives a few pointers that I, for one, will be seriously taking into consideration (not to mention the reference that I now have to order). </p>

<pre><code>[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see y&#39;all in 2 weeks!&#39;
</code></pre>
