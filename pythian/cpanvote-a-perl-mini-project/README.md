---
title: cpanvote - a Perl mini-project
url: cpanvote-a-perl-mini-project
format: html
created: 19 Feb 2010
original: the Pythian blog - http://www.pythian.com/news/8593/cpanvote-a-perl-mini-project
tags:
    - Catalyst
    - CPAN
    - Perl
    - REST
    - reviews
---

<h3>The Itch</h3>

<p>For many, CPAN is a Canadian Prairies-sized field of modules where it’s darn hard to separate the wheat from the chaff.</p>

<p>While the <a href="http://cpanratings.perl.org/">CPAN Ratings</a> service is the principal and official way CPAN tries to rank its distributions, for me at least, it doesn’t quite scratch the itch because . . . </p>

<ol><li>not all distributions have reviews.</li><li>even when there are reviews, they generally don’t answer the next question: <em>what should I use, instead?</em>.</li> </ol>

<h3>The Dream</h3>

<p>Consequently, for a while now I’ve been playing with ideas on how the rating could be improved. What I came up with so far is a very minimal system going straight for the goods, where a rating would consist of:</p>

<ol><li>The rating proper, which can be one of three values: “thumb-up”, “thumb-down”, or “neutral”.</li><li>If you give the distribution a thumb-down (or for that matter, even if you give it a thumb up), you can recommend another distribution to be used instead.</li><li>An accompanying short comment (140 characters or less so that it’s Twitter-ready. Longer, proper reviews can be done via <em>CPAN Ratings</em>).</li> </ol>

<p>Aaaand . . .  that’s it. Not exactly mind-blowing, but it’s so simple it could actually work.</p>

<h3>JFDI, you say?</h3>

<p>And now, since I’ve had a three-day week, I decided to give the idea a try and implement a prototype. Because I had only so many hours to devote to the project (hey, it was Valentine Day, after all), I’ve built it as a REST service. That way I didn’t have to spend any time on prettiness and, if the idea does to catch on, it can easily be grafted to a web site, IRC/IM bot, phone service, search.cpan.org (well, I can dream big, can’t I?), and so on.</p>

<p><a href="http://github.com/yanick/cpanvote">The cpanvote code</a> is on Github. It’s all rather untidy, but it’s (roughly) functional. Let’s have a little tour of the application via the example REST client <code>cpanvote.pl</code> included in the repo, shall we?</p>

<p>First, we need an account, which can be created via the client:</p>

<pre code="bash">
$ cpanvote.pl --register --user max --password min
</pre>

<p>(And yes, this way of creating users is rather brain-dead, but this is only a rough prototype, so it’ll do for now.)</p>

<p>Once an account is created, reviews are as simple as:</p>

<pre code="bash">
$ cpanvote.pl --user max --password min XML-XPathScript --yeah
</pre>

<p>or:</p>

<pre code="bash">
$ cpanvote.pl --user yanick --password foo Games::Perlwar --meh --comment &#34;could use a little Catalyst love&#34;
</pre>

<p>or:</p>

<pre code="bash">
$ cpanvote.pl --user yanick --password foo Dist-Release --neah --instead Dist-Zilla --comment &#34;nice try, but RJS is just better at it&#34;
</pre>

<p>For the time being, I have implemented only very simple per-distribution results, which can be queried via any browser:</p>

<pre code="bash">
$ lynx -dump http://localhost:3000/dist/Dist-Release/summary
---
comments:
    - nice try, but RJS is just better at it
    - cute
instead:
    - Dist-Zilla
vote:
    meh: ~
    neah: 1
    yeah: 1
</pre> <pre class="brush: plain;">
$ lynx -dump http://localhost:3000/dist/Dist-Release/detailed
---
-
    comment: nice try, but RJS is just better at it
    instead: Dist-Zilla
    vote: -1
    who: yanick
-
    comment: cute
    vote: +1
    who: max
</pre><h3>Test Server</h3>

<p>For the curious, I have an instance of the application running at <em>http://babyl.dyndns.org:3000</em> (<em>cpanvote.pl –host babyl.dyndns.org:3000 …</em>). It’s running a single-thread Catalyst with debug information, using a SQLite back-end on my home machine, which has rather pathetic bandwidth throughput, so please be gentle and don’t be too too surprised if it goes down.</p>

<h3>Whaddya think?</h3>

<p>This is the moment where I turn to the audience and prod them (that is, you) to see if I might be on to something, or if I’d be better to stop talking now. In other words, what’s your thought on this: <code>--yeah</code>, <code>--neah</code> or <code>--meh</code>? </p>

<h3>Further considerations</h3>

<p>Random thoughts for the next steps (assuming that there will be a next step).</p>

<ul><li>Review accounts could potentially be PAUSE-based.</li><li>Give peeps the opportunity to submit tags for the module alongside their review, and let the taxonomy short itself à la Deli.cio.us.</li><li>We could go meta all the way and vote on reviewers as well, which could give their opinion more weight.</li> </ul> 
