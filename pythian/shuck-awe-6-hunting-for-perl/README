---
url: shuck-awe-6-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/13405/shuck-awe-6-hunting-for-perl
created: 2010-06-16
tags:
    - Shuck & Awe
    - css
    - dbix-class
    - dist-zilla
    - file-chdir
    - heredoc
    - io-interactive
    - knitting
    - maze
    - Mojolicious
    - Perl
    - pgxn
    - PostgreSQL
    - smokebrew
    - trademark
---

# Shuck &amp; Awe #6: Hunting for Perl

 <pre>
[yanick@enkidu shuck]$ perl -MFile::Find::Rule \
    -e&#39;INIT{@ARGV=File::Find::Rule-&#62;file-&#62;name(&#34;*.news&#34;)-&#62;in(&#34;blogs&#34;)}&#39;
</pre>

<p>Remember me mentioning <a href="http://www.justatheory.com">David Wheeler</a>’s CPAN-like project for PostgreSQL? Well, by now it has an official name — <a href="http://pgxn.org/">PGXN</a> — and <a href="http://www.justatheory.com/computers/databases/postgresql/pgxn-development-project.html">the ball has now been set into motion</a>. This is going to be good.</p>

<p><a href="http://blogs.perl.org/users/bingos">bingos</a> decided to take the Dist::Zilla leap this week. <a href="http://blogs.perl.org/users/bingos/2010/06/late-to-the-party-but-i-brought-bottles.html">A few plugins have already been churned out</a> as the result.</p>

<p><i>Danger Will Robinson!</i> If you are using <a href="http://search.cpan.org/dist/File-chdir">File::chdir</a>, <a href="http://www.dagolden.com">David Golden</a> warns that Perl 5.13.1 broke it by fixing a tied variable-related bug. Things are expected to be back to normal with Perl 5.13.2.</p>

<p><span id="more-13405"></span></p>

<p>In a glorious display of shininess, <a href="http://onionstand.blogspot.com">garu</a> <a href="http://onionstand.blogspot.com/2010/06/tweetylicious-twitter-like.html">shares with us Tweetylicious</a>, a microblogging Twitter-lookalike written using <a href="http://search.cpan.org/dist/Mojolicious-Lite">Mojolicious::Lite</a>. He even organized the commits for the project in a tutorialish way, making it the perfect introduction to Mojolicious.</p>

<p><a href="http://mt.endeworks.jp/d-6/">Daisuke Maki</a> brings some mind-boggling news from Japan. A rake and ne’er-do-well seems to have applied for the copyright on the word ‘Perl’ in Japan… and <a href="http://mt.endeworks.jp/d-6/2010/06/perl-trademark-in-japan.html">the request has been accepted</a>. Japanese mongers are not amused.</p>

<p><a href="http://oylenshpeegul.vox.com">oylenshpeegul</a> came up with the pattern for a <a href="http://oylenshpeegul.vox.com/library/post/knitteddishcloth.html">knitted Perl’s camel dishcloth</a> (which he wrote using POD, natch). Good timing too, considering that we are in the midst of <a href="http://www.wwkipday.com/">World Wide Knit in Public Day</a>.</p>

<p>Ashley Pond V delights us with a clever mix of <a href="http://sedition.com/a/2953">Perl maze generator and CSS wizardry</a>.</p>

<p><a href="http://varlogrant.blogspot.com">Dave Jacoby</a> shares <a href="http://varlogrant.blogspot.com/2010/06/absolutely-awesome-perl-modules.html">his new-found love for IO::Interactive</a>.</p>

<p><a href="http://blog.afoolishmanifesto.com">fREW</a> announces the <a href="http://blog.afoolishmanifesto.com/archives/1352">arrival of DBIx::Class::DeploymentHandler</a>, which is touted as being even more awesome than <a href="http://search.cpan.org/dist/DBIx-Class">DBIx::Class::Schema::Versioned</a>. It slices, it dices, it does upgrades <em>and</em> downgrades!</p>

<p><a href="http://ap0calypse.agitatio.org">ap0calypse</a> begs you to do your part to stop the all-to-general terrible abuse of <code>print</code> statements <a href="http://ap0calypse.agitatio.org/articles/please-use-here-documents">and use heredocs</a> whenever justified. </p>

<p><a href="http://use.perl.org/~Alias">Adam Kennedy</a> reports that the top 100 CPAN modules (in term of dependencies) <a href="http://use.perl.org/~Alias/journal/40387">suddenly gained some weight</a>. We are still unsure of the specific cause. Personally, I blame it on the codenaming of the Windows port of Perl after delicious flavors of icecream.</p>

<p>Inspired by <code>perlbrew</code>, that nectar from the gods, bingos <a href="http://blogs.perl.org/users/bingos/2010/06/smokebrew---it-is-like-perlbrew-but-different.html">came out with smokebrew</a>, which follows the same general idea, but is geared toward the creation of Perl testing environments.</p>

<pre>
[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see y&#39;all in 2 weeks!&#39;
</pre>
