---
url: shuck-awe-2-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/11341/shuck-awe-2-hunting-for-perl
created: 21 Apr 2010
tags:
    - cloud
    - CPAN
    - Dancer
    - maintenance
    - meta.yml
    - modules
    - Mojolicious
    - Moose
    - Perl
    - perlbrew
    - sunaba
    - versions
    - Shuck & Awe
---

# Shuck &amp; Awe #2: Hunting for Perl

<p><i><tt>[yanick@enkidu shuck]$ tail -f news | perl -nE&#39;say if /interesting/&#39;</tt></i></p>

<p>Huzzah! It’s official, <a href="http://www.perl.org/get.html">Perl 5.12</a> is out! If you haven’t already, check out the <a href="http://search.cpan.org/~jesse/perl-5.12.0/pod/perl5120delta.pod">changelog</a>! As one might expect, this little piece of news made its way on several blogs, both internal and <a href="http://arstechnica.com/open-source/news/2010/04/perl-5-development-resumes-version-512-released.ars?utm_source=rss&#38;utm_medium=rss&#38;utm_campaign=rss">external</a> to the Perl community.</p>

<p>Module authors, there are some other changes at the horizon for your modules’ META files as well. <a href="http://www.dagolden.com">David Golden</a> <a href="http://www.dagolden.com/index.php/759/cpan-meta-spec-version-2-released">announced</a> the release of version 2 of the <a href="http://search.cpan.org/perldoc?CPAN::Meta::Spec">CPAN META Spec</a>. One of the biggest changes is the adoption of JSON (over YAML) as the preferred serialization format.</p>

<p>Plabo Marin-Garcias wrote about <a href="http://pablomarin-garcia.blogspot.com/2010/04/managing-multiple-local-perl.html">how to manage multiple local perl installations using perlbrew</a>. If, for whatever reason, you have to juggle with more than one perl installation on the same machine <a href="http://search.cpan.org/dist/App-perlbrew">App::perlbrew</a>, written by <a href="http://search.cpan.org/~gugod/">Gugod</a>, this might be a (gu)godsend that will make you sing hosannas for months to come…</p>

<p>In a nice little <a href="http://www.modernperlbooks.com/mt/2010/04/removing-friction.html">success story</a>, chromatic tells us how <a href="http://dzil.org/">Dist::Zilla</a>, <a href="http://github.com">Github</a> and <a href="http://github.com/gitpan">Gitpan</a> are helping to alleviate the complexity of distribution maintenance, turning what many consider a chore into… well, okay, still a chore, but at least a well-oiled, smoother one. </p>

<p>It’s a <a href="http://use.perl.org/~Alias/journal/40312">web framework smackdown</a>! <a href="http://ali.as">Adam Kennedy</a> writes a series of articles in which he gets his feet wet with two modern Perl web frameworks:<a href="http://search.cpan.org/dist/Mojolicious/">Mojolicious</a> and <a href="http://search.cpan.org/dist/Dancer/">Dancer</a>.</p>

<p>All work and no play makes Jack a dull boy? No more! <a href="http://yapgh.blogspot.com/2010/04/gamesfrozenbubble-it-is-start.html">Kartik announced</a> that the beloved game <a href="http://www.frozen-bubble.org/">Frozen Bubble</a> is now directly <a href="http://search.cpan.org/~kthakore/Games-FrozenBubble">available on CPAN</a>.</p>

<p><a href="http://blogs.perl.org/users/sawyer_x/2010/04/get-the-damned-version.html">Sawyer X got fed-up of manually hunting for module versions</a>and created <a href="http://search.cpan.org/dist/Module-Version/">Module::Version</a> to take care of the deed. Turned out he wasn’t the first to have that itch — in the comments people also recommended <a href="http://search.cpan.or/dist/Module-Which">Module::Which</a> and <a href="http://search.cpan.org/dist/V">V</a>.</p>

<p>On the microscopic side of things, <a href="http://onionstand.blogspot.com/2010/04/one-liner-tip-aliases.html">garu shared a few shell aliases</a> that will make your one-liner even tinier. </p>

<p>Tags. Everything taste better with tags. In consequence, <a href="http://blogs.perl.org/users/ovid/">Ovid</a> presented <a href="http://blogs.perl.org/users/ovid/2010/04/testclass-tags.html">a way to add tags to Test::Classtests</a>.</p>

<p>Moose has a <a href="http://moose.perl.org/">new website</a>, <a href="http://stevan-little.blogspot.com/2010/04/new-moose-website.html">Stevan Little reports</a>. Because it’s not fun till it turns meta, the code producing the site is itself <a href="http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=gitmo/moose-website.git;a=summary">available via a git repository</a>.</p>

<p>Finally, it looks like <a href="http://blog.plackperl.org/2010/04/sunaba---perl-web-apps-in-the-cloud.html">miyagawa went on a hacking frenzy</a>. The result is <a href="http://sunaba.plackperl.org/">Subana</a> a cloud service that can run any <a href="http://search.cpan.org/dist/Plack/">Plack</a> application.</p>

<p><i><tt>^D<br />[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see ya in 2 weeks!&#39;</tt></i></p>

