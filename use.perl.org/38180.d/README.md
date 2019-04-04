---
title: CPAN Patching with Git
format: html
created: 29 Dec 2008
original: use.perl.org - http://use.perl.org/article.pl?sid=08/12/29/202226
tags:
    - Perl 
    - Git::CPAN::Patch
---

<p>A few months ago, brian posted a blog entry
about
<a href="http://use.perl.org/~brian_d_foy/journal/37664" rel="nofollow">patching modules using Git</a>.
In the ensuing discussion, I pointed at a possible way to
automatise the process a step further by punting the generated
patch to rt.cpan.org.  The hack was well-received  and, with
(very) minimal coaxing, I was subsequently convinced to
expand on the idea for the Perl Review.</p><p>The resulting piece is now available in
<a href="http://theperlreview.com/" rel="nofollow">TPR 5.1</a>. In the article, the
initial command-line hack has morphed into
four scripts -- <code>git-cpan-init</code>, <code>git-cpan-clone</code>,
<code>git-cpan-update</code> and <code>git-cpan-sendpatch</code> -- that
pretty much take care of all the administrative
overhead of module patching.  In most cases,
grabbing a distro, fixing a bug and sending the
patch can be done in four lines:</p><blockquote><div><p> <tt>    $ git cpan-init Some::Module<br></br>    $ git checkout -b mypatch<br></br>   <nobr> <wbr></wbr></nobr>...hack hack hack...<br></br>    $ git rebase -i cpan<br></br>    $ git cpan-sendpatch</tt></p></div> </blockquote><p>And, no, the lack of hyphen between <code>git</code> and <code>cpan-X</code>
isn't a typo; the article also covers how
to seamlessly integrate the new scripts into the
git infrastructure (as Edna Mode would say,
<i>it's a non-feature, dahling</i>).</p><p>Of course, I'm burning to say more, but I'll have to stop here.
To know the whole story, you'll have to wait for The Perl Review
to land in your mailbox (you are subscribed to TPR, <i>right?</i>).</p><p> <i>cross-posted from <a href="http://babyl.dyndns.org/techblog" rel="nofollow">Hacking Thy Fearful Symmetry</a>.</i> </p>
