---
url: shuck-awe-4-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/12559/shuck-awe-4-hunting-for-perl
created: 2010-05-21
tags:
    - Shuck & Awe
    - bioperl
    - Catalyst
    - CPAN
    - cpants
    - database
    - debugging
    - design
    - games
    - microsoft
    - Mojolicious
    - psgi
    - qa
    - sharding
    - Test::Class
    - testing
    - WWW::Mechanize
    - Linux
    - Log Buffer
    - MySQL
    - mysqlconf
    - network
    - networking
    - news
    - OOW
    - open source
    - operating systems
    - Oracle
    - Oracle 11g
    - performance
    - Perl
    - PostgreSQL
    - presentations
    - Pythian
    - RAC
    - security
    - software
    - SQL Server
    - Sydney
    - Ubuntu
    - UKOUG
    - video
    - virtualization
    - Windows
---

# Shuck &amp; Awe #4: Hunting for Perl

 <pre>
[yanick@enkidu shuck]$ cat my_feeds | \
    perl -MXML::Feed \
         -ne&#39;say( (XML::Feed-&#62;parse($_)-&#62;entries)[0]-&#62;summary ) if rand() &#62; 0.5 &#39;
</pre>

<p><a href="http://csjewell.dreamwidth.org/">Curtis Jewell</a> followed up on <a href="http://use.perl.org/~Alias/journal/40184">an old post by Adam Kennedy</a> and <a href="http://csjewell.dreamwidth.org/13095.html">checked out if shuffling things around really improve compression</a>. From the results, there seems to be very little blood to be squeezed out of that stone. </p>

<p><a href="http://use.perl.org/~jjore/">jjore</a> came up with a very clever hack to <a href="http://use.perl.org/~jjore/journal/40350">stop the debugger when a test fails</a>. Not only it is extremely useful, but the hack itself provides a lot of insight and food for thought for anyone attracted to the dark arts of under-the-Perl-interpreter-hood meddling.</p>

<p><span id="more-12559"></span></p>

<p><a href="http://jquelin.blogspot.com/">Jerome Quelin</a> <a href="http://jquelin.blogspot.com/2010/05/gamesrisk-speaks-your-language.html">invites helpful-minded polyglots to provide translations</a> for <a href="http://search.cpan.org/dist/Games-Risk">prisk</a>, a Perl clone of the classic game <em>Risk</em>.</p>

<p><a href="http://www.wgz.org/~chromatic">chromatic</a> had a short piece that demonstrates with a telling example how tricky it can be to <a href="http://www.modernperlbooks.com/mt/2010/05/perl-and-the-least-surprised.html">design a language so that it behaves with the least amount of surprise</a>. </p>

<p>Daisuke Maki reported that <a href="http://blog.perlassociation.org/2010/05/perl-5-12-1-is-out.html">Perl 5.12.1 is out</a>! Right behind, Curtis Jewell <a href="http://csjewell.dreamwidth.org/12912.html">preemptively announced that its Strawberry port is not far behind</a>. The beta should be available at the beginning of June, and the real McCoy by early July.</p>

<p><a href="http://szabgab.com/">Gabor Szabo</a> wrote a blow-for-blow narration of the hunt and subsequent squishing of a bug in <a href="http://padre.perlide.org/">Padre</a>. Quite interesting if you are wondering how other hackers tackle their debugging sessions.</p>

<p><a href="http://use.perl.org/~cjfields/">cjfields</a> <a href="http://use.perl.org/~cjfields/journal/40353">pointed out</a> that <a href="http://news.open-bio.org/news/2010/05/bioperl-has-moved-to-github/">BioPerl has moved to Github</a>.</p>

<p><a href="http://headrattle.blogspot.com">Jay Hannah</a> has <a href="http://headrattle.blogspot.com/2010/05/catalyst-and-quality-assurance-bliss.html">nothing but love for QA done with Catalyst and WWW::Mechanize</a>. He’s also mentioning that he uses <a href="http://hudson-ci.org/">Hudson</a> as his integration server. I’ll have to look into that. Not only we need one at $work, but the possibility to join forces with the cyborg brother of our own dreaded <a href="http://www.pythian.com/news/author/hudson/">head sysadmin</a> is just too good to pass.</p>

<p>Remember when the Microsoft spiders DOSed the CPANTS site a few months back? Well, <a href="http://blogs.perl.org/users/cpan_testers/2010/05/microsoft-attack-cpan-testers-again.html">they are at it again</a>. It is reported that Microsoft subsequently got in touch with the CPANTS folks and apologised. Again. I know, we shouldn’t attribute to malevolence what can be explained by incompetence, but come on! This is getting silly. In all cases, web crawlers of around the world, please remember: obeying the rules of <em>robots.txt</em>, it’s not just a good idea — it’s good manners.</p>

<p><a href="http://blogs.perl.org/users/ovid/">Ovid</a> wrote about <a href="http://blogs.perl.org/users/ovid/2010/05/sharding-your-database.html">sharding your database</a>. Very good introduction if, like me, you never heard that expression before, and suspect it involves a wood chipper. He also wrote a nice little entry on <a href="http://blogs.perl.org/users/ovid/2010/05/whats-testclass-doing.html">how to properly deal with startup and shutdown methods in Test::Class</a>.</p>

<p>And speaking of testing, <a href="http://pablomarin-garcia.blogspot.com">Pablo Marin-Garcias</a> has an <a href="http://pablomarin-garcia.blogspot.com/2010/05/some-perl-modules-for-web-testing-and.html">awesome roundup of web testing modules</a>.</p>

<p><a href="http://blogs.perl.org/users/leo_lapworth/">Leo Lapworth</a> coughed politely and brought attention to the fact that <a href="http://blogs.perl.org/users/leo_lapworth/2010/05/20000-distributions-on-cpan.html">there’s now over 20,000 distributions on CPAN</a>. With that kind of selection, is it really a surprise that some people claim they program in CPAN, and Perl is only the mean to tap into it? </p>

<p><a href="http://onionstand.blogspot.com">Garu</a>, <a href="http://onionstand.blogspot.com/2010/05/getting-back-at-mst.html">cheekily notes</a> that <a href="http://www.shadowcat.co.uk/blog/matt-s-trout/">Matt S. Trout</a>’s blog hasn’t been updated for a few weeks. Which wouldn’t be very interesting news <em>if</em> MST wouldn’t have sworn, when he launched the Perl Ironman contest, that “<em>If [he] loses, [he&#39;s] gonna let you guys pick a colour and a theme, and I’ll do a talk about that theme with my hair dyed that colour</em>“. Ooops. It goes without saying, there’s already a thread forming in the comments about which hue would suit our favorite curmudgeon. My favorite so far is the <a href="http://haircrazy.com/brand/special-effects/">Bright as <em>[censored]</em> yellow</a>, by Special Effects. </p>

<p>Want to see some of the yumminess that can be generated with <a href="http://mojolicious.org/">Mojolicious</a>? <a href="http://vti.showmetheco.de">vti</a> provides links to a few <a href="http://vti.showmetheco.de/articles/2010/05/more-mojolicious-websocket-examples.html">nifty Mojolicious WebSocket examples</a>.</p>

<p>You’re more inclined toward PSGI? Then <a href="http://perlalchemy.blogspot.com">Zbigniew Lukasiak</a> mused a wee bit about <a href="http://perlalchemy.blogspot.com/2010/05/psgi-and-object-oriented-programming.html">PSGI and Object Oriented programming</a>.</p>

<p>And, finally, <a href="http://null.perl-hackers.net">Alberto Simões</a> wrote a report on the <a href="http://news.perlfoundation.org/2010/05/running-grants---a-summary-rep.html">status of the diverse running TPG grants</a>. </p>

<pre>
[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see ya in 2 weeks!&#39;
</pre>
