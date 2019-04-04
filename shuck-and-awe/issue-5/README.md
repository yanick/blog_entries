---
url: shuck-and-awe-5
format: html
created: 4/Jun/2010
original: The Pythian Blog - http://www.pythian.com/news/12889/shuck-awe-5-hunting-for-perl/
tags:
    - Shuck & Awe
    - Perl
    - CPAN
    - Dancer
    - DBIx::Class
    - Dist::Zilla
    - Perl hosting
    - PostgreSQL
    - shuffling
    - Strawberry Perl
    - survey
    - weakened references
    - web development
---

# Shuck & Awe #5: Hunting for Perl

<pre>[yanick@enkidu shuck]$  perl -MWWW::Robot
my $robot = WWW::Robot-&gt;new(
    NAME =&gt; 'shuck', VERSION =&gt; 0.1, EMAIL =&gt; 'blogger@pythian.com'
);
$robot-&gt;addHook( 'follow-url-test' =&gt; sub { 1 } );
$robot-&gt;addHook( 'invoke-on-contents' =&gt; sub { print $_[5] if rand()
&gt; 0.5 } );
$robot-&gt;run( 'http://blogs.perl.com' );
^D

</pre>
<p>First, <a href="http://poisonbit.wordpress.com">Inigo Tejedor</a> <a
href="http://poisonbit.wordpress.com/2010/06/01/about-perl-programming-survey/">reminds
us</a> that we have until Thursday June 3rd (yes, <em>tomorrow</em>) to fill
out the <a href="http://perl.websurvey.net.au/">Perl programming survey</a>.
If you haven&#8217;t done so already, what are you waiting for? Stop reading
this blog entry right now and go do your duty. No, seriously, go!</p>
<p>And no peeking back until you&#8217;re done!</p>
<p>&#8230; so, survey&#8217;s filled out? Good. Now we can continue.</p>

<p><span id="more-12889"></span></p>
<p><a href="http://marcus.nordaaker.com">Marcus Ramberg</a>  <a
href="http://marcus.nordaaker.com/2010/06/dbix-class-about-to-switch-to-git">echoes
an IRC chat</a> announcing that <a
href="http://search.cpan.org/dist/DBIx-Class">DBIx::Class</a> is switching its
official repository from svn to <a
href="http://github.com/haarg/DBIx-Class">git</a>.</p>
<p><a href="http://curiousprogrammer.wordpress.com">Jared</a> contests the
claim that <a
href="http://curiousprogrammer.wordpress.com/2010/05/31/super-programming-languages/">the
choice of a language ultimately makes little difference</a>.</p>

<p><a href="http://blog.urth.org/">Dave Rolsky</a> presents his views on the
<a href="http://blog.urth.org/2010/05/distzilla-pros-and-cons.html">advantages
and pitfalls</a> of using <a
href="http://search.cpan.org/dist/Dist-Zilla">Dist::Zilla</a>. </p>
<p><a href="http://blogs.perl.org/users/ovid">Ovid</a> is showing us how to
calculate the Roman date of a <a
href="http://blogs.perl.org/users/ovid/2010/05/dates-in-latin.html">most happy
event</a>.</p>
<p><a href="http://www.shadowcat.co.uk/blog/matt-s-trout/iron-mad/">The
results are in</a> for the hair color and talk that <a
href="http://www.shadowcat.co.uk/blog/matt-s-trout">Matt S.  Trout</a> will
have to adopt as a penalty for failing the Perl Ironman contest. His hair will
be dyed a pristine snow-white, and his talk will be about how Module::Build is
better than ExtUtils::MakeMaker, and how does this reflect on the design of
Perl 7 and the fact that PHP is the future of web development, which will tie
in in the historic review of MVCs, from Pacman to Django, with mention that
patches are indeed welcome, and that &#8212; by the by &#8212; ferrets are an
excellent source of (ferrety) food, perhaps due to the fact that Apple is the
devil incarnate, which is not a reason to use cognitive science to improve
HTML::Zoom&#8217;s usability. It is a safe bet to say that the show is
definitively going to be worth the admission price.</p>

<p>A silly little trick, but perhaps unknown to some: <a
href="http://theworkinggeek.com/">Andy Lester</a> shows the easy way to <a
href="http://perlbuzz.com/2010/05/how-to-shuffle-a-list-in-perl.html">shuffle
a list in Perl</a>.</p>
<p>Ashley Pond V has a success story about how <a
href="http://sedition.com/a/2945">Perl and DBIx::Class saved his AdSense
account from the Puritan mob</a>.</p>
<p><a href="http://blog.afoolishmanifesto.com">fREW Schmidt</a> shares a quick
trick on <a href="http://blog.afoolishmanifesto.com/archives/1344">how to sync
with multiple git repositories</a> with a single <tt>git push all</tt>.</p>

<p><a href="http://csjewell.dreamwidth.org">Curtis Jewell</a> let us know that
<a href="http://csjewell.dreamwidth.org/14161.html">the new Strawberry July
2010 Beta 1 is out</a>.</p>
<p><a href="http://leonerds-code.blogspot.com">Paul Evans</a> began with
weakening references in his code, and ended up <a
href="http://leonerds-code.blogspot.com/2010/05/weasels-in-code.html">seeing
weasels</a> crawling all over his objects.</p>
<p><a href="http://use.perl.org/~Alias/">Adam Kennedy</a> reports a <a
href="http://use.perl.org/~Alias/journal/40358">most flattering quote</a>
coming from Rob Mensching, the creator of Windows Installer XML and the WiX
toolkit.</p>

<p><a href="http://www.justatheory.com">David Wheeler</a> does a little bit of
<a
href="http://www.justatheory.com/computers/databases/postgresql/pgan-bikeshedding.html">PGAN
bikeshedding</a>.  Which wouldn&#8217;t be that noteworthy until you realize
that PGAN is a PostgreSQL extension distribution system based on CPAN &#8212;
for anyone using PostgreSQL and knowing the power of CPAN, that should be
enough to trigger a few dreamy &#8220;ooooooh&#8221;s. </p>
<p>You want to develop a modern Perl web application, but can&#8217;t find a
hosting company that lets you have the environment to do so? <a
href="http://blog.patspam.com">Patrick Donelan</a> might have <a
href="http://blog.patspam.com/2010/serve-up-dancer-webapps-for-six-bucks">a
very enticing proposition for you</a> with his shared hosting project.</p>

<pre>
[yanick@enkidu shuck]$ perl -E'sleep 2 * 7 * 24 * 60 * 60 # see y'all in 2 weeks!'
</pre>

