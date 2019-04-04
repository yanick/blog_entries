---
url: shuck-awe-3-hunting-for-perl
original: the Pythian blog - http://www.pythian.com/news/11869/shuck-awe-3-hunting-for-perl
created: 5 May 2010
tags:
    - android
    - book
    - cell phone
    - CPAN
    - formatting
    - github
    - linkedin
    - Perl
    - Perl6
    - pictures
    - podcast
    - yapc
    - Shuck & Awe
---

# Shuck &amp; Awe #3: Hunting for Perl
 <pre>
[yanick@enkidu shuck]$ echo &#34;original json_pretty taken from <a href="http://twitter.com/hanekomu">hanekomu&#39;s tweet</a>&#34;
[yanick@enkidu shuck]$ cat news.json | \
    perl -0007 -MJSON -nE&#34;say for @{from_json(\$_)-&#62;{interesting}}&#34;
</pre>

<p>Want to help Perl 6, and collect some booty in the process? <a href="http://perlgeek.de/blog-en/">Moritz Lenz</a> has issued <a href="http://perlgeek.de/blog-en/perl-6/contribute-now-announce.html">the first of a series of Perl 6 challenges</a>. Fulfill the challenge, and get a chance to win mind-bogglingly fabulous prizes (well, okay, t-shirts for now). This week’s challenge doesn’t even require Perl 6 knowledge — it’s all about <a href="http://perlgeek.de/blog-en/perl-6/contribute-now-proto-website.html">creating a website</a> for <a href="http://github.com/masak/proto/">proto</a>.</p>

<p>Talking of Perl 6, <a href="http://use.perl.org/~masak">masak</a> announced the <a href="http://use.perl.org/~masak/journal/40337">release of Yapsi</a>, a Perl 6 compiler written in Perl 6.</p>

<p><span id="more-11869"></span></p>

<p>Back to more day-to-day matters, in a poignant lament, <a href="http://blogs.perl.org/users/ovid/">Ovid</a> bemoans what he knows <a href="http://blogs.perl.org/users/ovid/2010/05/things-i-cant-have.html">he can’t have</a>. Indeed, woe is he, for he is cursed to walk the Earth in company of teams who don’t believe in the goodiness of <a href="http://search.cpan.org/dist/Perl-Tidy/">perltidy</a>. One can only hope that, one day, his cohorts will see the light, and perhaps install a repository commit hook akin to, oh, I don’t know, <a href="http://use.perl.org/~Yanick/journal/35626">this one</a>. </p>

<p>On <a href="http://use.perl.org/article.pl?sid=10%2F05%2F03%2F1121240">use.perl.org</a>, kid51 reports that the <a href="http://yapc2010.com/yn2010/schedule">schedule for presentations at YAPC::NA::2010 in Columbus, Ohio</a> is out. And so is the <a href="http://news.perlfoundation.org/2010/03/yapcna-2011-call-for-venue.html">call for the YAPC::NA::2011 venue</a>.</p>

<p><a href="http://curiousprogrammer.wordpress.com/author/curiousprogrammer/">Jared</a> has heaped a lot of <a href="http://curiousprogrammer.wordpress.com/2010/05/02/perl-links-2010-17/">interesting Perl links</a> in a blog entry. There are Perl blog aggregators, articles about <a href="http://padre.perlide.org">Padre</a>, the mention of a new <a href="http://www.pythian.com/news/11341/shuck-awe-2-hunting-for-perl/">Perl roundup</a> that inexplicably feels familiar, and more.</p>

<p>Likewise, <a href="http://transfixedbutnotdead.com">draegtun</a> went a similar route, and listed all <a href="http://transfixedbutnotdead.com/2010/04/30/podcasts-perl/">the Perl related podcasts he susbcribes to</a>. </p>

<p><a href="http://szabgab.com">Gabor Szabo</a> did a little comparative study, and it seems that <a href="http://szabgab.com/blog/2010/05/1272792637.html">Perl is behind the curve, as far as LinkedIn language groups are concerned</a>. Darn. If you have any interest in <a href="http://www.linkedin.com/groups?gid=74787">Bricolage</a>, <a href="http://www.linkedin.com/groups?gid=2460957">Padre</a>, <a href="http://www.linkedin.com/groups?gid=1734207">Catalyst</a> or any of the other Perl groups, now is the time to join and make our presence felt a little more.</p>

<p>Cell phone running Android? Gabor and <a href="http://blogs.perl.org/users/sawyer_x/">SawyerX</a> gave a presentation on their dabbling with Perl on Android. The stereo recount of the presentation is <a href="http://blogs.perl.org/users/sawyer_x/2010/05/perl-on-android-progressing.html">here</a> and <a href="http://szabgab.com/blog/2010/05/1272784948.html">there</a>. </p>

<p>For the Windows crowd, <a href="http://csjewell.dreamwidth.org/">Curtis Jewell</a> gleefully trumpets <a href="http://csjewell.dreamwidth.org/12275.html">the April 2010 release of Perl Strawberry</a>. </p>

<p><a href="http://www.amazon.com/dp/0321496949?tag=theeffeperl-20&#38;camp=14573&#38;creative=327641&#38;linkCode=as1&#38;creativeASIN=0321496949&#38;adid=089502333VCNP2F6JD7F&#38;">Effective Perl Programing</a> is hot off the presses. The <a href="http://www.effectiveperlprogramming.com/errata">errata page</a>, <a href="http://www.effectiveperlprogramming.com/blog/225">brian d foy pragmatically points out</a>, is also open for business.</p>

<p>For all the mad scientists in the room, <a href="http://blogs.perl.org/users/jeffrey_kegler/">Jeffrey Kegler</a> announced the <a href="http://blogs.perl.org/users/jeffrey_kegler/2010/05/bnf-parsing-and-linear-time.html">release of Marpa</a>, a general <a href="http://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form">BNF parser</a> on CPAN. </p>

<p>On the OO front, <a href="http://use.perl.org/~schwern/">Schwern</a> has announced <a href="http://search.cpan.org/dist/Object-Id">Object::ID</a>. With the mere addition of a ‘<em>use Object::ID</em>‘ <a href="http://use.perl.org/~schwern/journal/40340">any (and I really mean any) class will instanteously sprout unique object identifiers</a>.</p>

<p>The <a href="http://gist.github.com/">Gist</a> service offered by <a href="http://github.com">Github</a> is a wonderful way to share code snippets. <a href="http://blog.johngoulah.com">John Goulah</a> makes it even more accessible by <a href="http://blog.johngoulah.com/2010/05/gist-from-the-command-line/">providing a way to create gists from the command line</a>.</p>

<p>For those interested by the faces behind the minds behind Perl (figuratively speaking, of course. Anatomically speaking, we can only hope that the first is in front of the second, with the third safely inside), <a href="http://blogs.perl.org/users/domm/">domm</a> <a href="http://blogs.perl.org/users/domm/2010/05/photos-from-the-perl-qa-hackathon-2010-in-vienna.html">mentions</a> that <a href="http://www.flickr.com/photos/49780319@N04/sets/72157623843507459/">the hackathon pictures are up on Flickr</a>. </p>

<p>Still on the topic of celebrities, <a href="http://ali.as">Adam Kennedy</a> will <a href="http://use.perl.org/~Alias/journal/40335">be on American soil in May</a>. If you are part of a Perl Monger group near Redmond or Boston, you might consider summoning the Great Old One for a presentation…</p>

<p>Not tired of celebrities yet? In that case, <a href="http://transfixedbutnotdead.com">draegtun</a> has a nifty blog entry pointing out <a href="http://transfixedbutnotdead.com/2010/04/29/famous-perl-programmers/">a few famous Perl programmers</a>. The inventor of the original wiki? A Perl programmer. Creator of <a href="http://jquery.com">jQuery</a>? Another Perl programmer. The mind behind <a href="http://flickr.com">Flickr</a>? Yet another Perl programmer. The father of modern psychology? Okay, <em>not</em> a Perl programmer. Although I should probably double-check who actually wrote the first version <a href="http://search.cpan.org/dist/Chatbot-Eliza/">Chatbot::Eliza</a>. One never knows…</p>

<pre>
[yanick@enkidu shuck]$ perl -E&#39;sleep 2 * 7 * 24 * 60 * 60 # see ya in 2 weeks!&#39;
</pre>
