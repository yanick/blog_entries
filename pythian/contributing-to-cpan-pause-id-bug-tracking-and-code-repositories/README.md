---
url:               contributing-to-cpan-pause-id-bug-tracking-and-code-repositories
format:            html
created:           2010-02-03
original:      the Pythian blog - http://www.pythian.com/news/7877/contributing-to-cpan-pause-id-bug-tracking-and-code-repositories   
tags:
    - CPAN
    - Perl
---

# Contributing to CPAN: PAUSE id, Bug Tracking and Code Repositories

<div class="vignette">
<img 
alt="CPAN Wants You!" 
src="__ENTRY_DIR__/cpan-wants-you.jpg" title="CPAN Wants You!" width="300" />
</div>

<p>Want to contribute to your favorite CPAN module, or maybe create your own, but don’t have the foggiest idea how to do it? Here are a few notes, tips, tricks, and links that might help you get started.</p>

<h3>PAUSE id</h3>

<p>While bringing awesome street cred, having a <a href="http://pause.perl.org/pause/query?ACTION=request_id">PAUSE id</a> is strictly necessary only if you want to maintain or co-maintain a module. If you just want to contribute code, you’ll perfectly be able to do without, as it will usually be done via patches submitted to a bug tracking system, a code repository or using good ol’ email.</p>

<h4>Becoming a co-maintainer</h4>

<p>Becoming the co-maintainer of a module gives you the power to upload authorized releases of the modules on CPAN. To become one, the maintainer of the module simply has to promote you as such on PAUSE.</p>

<h4>Creating a new module</h4>

<p>You want to create your own module? <span id="more-7877"></span> Excellent! But before you do it, make sure that you . . . </p>

<ul><li> you verified on <a href="http://search.cpan.org">CPAN</a> that there’s not already a module that already scratch that particular itch.</li><li>You made sure that the module uses a <a href="http://pause.perl.org/pause/query?ACTION=pause_namingmodules">descriptive and pertinent namespace</a>.</li> </ul>

<p>Once this is done, go ahead: log on <a href="http://pause.cpan.org">PAUSE</a> and <a href="https://pause.perl.org/pause/authenquery?ACTION=apply_mod">register the module</a>.</p>

<h4>Adopting an abandoned module</h4>

<p>There’s a module apparently abandoned by its owner that you’d love to take over? The procedure for that is given in the <a href="http://www.cpan.org/misc/cpan-faq.html#How_adopt_module">CPAN FAQ</a>, and it can be boiled down to:</p>

<ul><li>Try to get in contact with the current maintainer.</li><li>If you reach him or her, make puppy eyes and ask if you can take over.</li><li>If they are agreeable, they will flip over the maintenance of the module to you on PAUSE, and that’s all there is to it.</li><li>If you tried their email addresses, poked around in mailing lists, forums and other places without any luck, wait a little bit (a couple of weeks) and contact the PAUSE admins.</li> </ul><h4>Module created! How do I upload releases, now?</h4>

<p>You upload new versions of a module via the <a href="https://pause.perl.org/pause/authenquery?ACTION=add_uri">PAUSE interface</a> or via ftp.</p>

<p>Alternatively, and more conveniently, you can also use the <code>cpan-upload</code> script provided by <a href="http://search.cpan.org/~rjbs/CPAN-Uploader">CPAN::Uploader</a>.</p>

<h3>Bug Tracking</h3>

<p>Contributing to a module means fixing bugs or implementing new enhancements. To find those, who are you gonna call? The Bug Tracker!</p>

<h4>rt.cpan.org</h4>

<p>By default, every module on CPAN has a bug tracking queue on <a href="//rt.cpan.org">rt.cpan.org</a>. For example, the one for Git::CPAN::Patch is at <a href="http://rt.cpan.org/Public/Dist/Display.html?Name=Git-CPAN-Patch">http://rt.cpan.org/Public/Dist/Display.html?Name=Git-CPAN-Patch</a>.</p>

<p>Bug reporting can be done via the web interface, or by sending an email to <code>bug-<em>module</em>@rt.cpan.org</code> (e.g., <code>bug-git-cpan-patch@rt.cpan.org</code>).</p>

<h4>…or somewhere else</h4>

<p>Sometimes, the module’s maintainer uses a different bug tracking system. You’ll typically find it mentioned in the POD, or in the <code>META.yml</code>:</p>

<pre code="bash">
$ curl -L http://search.cpan.org/dist/Git-CPAN-Patch/META.yml | \
  perl -MYAML -0 -E&#39;say Load(&#60;&#62;)-&#62;{resources}{bugtracker}&#39;

http://rt.cpan.org/NoAuth/Bugs.html?Dist=Git-CPAN-Patch
</pre>

<p>If you don’t feel inclined to dig into <code>META.yml</code> for information, there is a <a href="http://userscripts.org/scripts/show/31748">Greasemonkey script</a> that will do it for you, and automatically add a link to the bugtracker (along some other goodies) on the module’s CPAN page.</p>

<h4>…or here, there and everywhere</h4>

<p>What if the bugs are kept on rt.cpan.org, and on the local bug tracking system of Github, and a few other places? You can either follow them manually, or you can get funky and experiment with <a href="http://syncwith.us/sd/using">SD</a>, a peer-to-peer ticket tracking system that can sync with and merge the information of several online bug tracking systems. SD, it goes without saying, can be found on CPAN as <a href="http://search.cpan.org/dist/App-SD">App::SD</a>.</p>

<h3>Code Repository</h3>

<p>Most, but not all, modules have a public code repository somewhere out there. Just like for the bug tracking system look for it in the POD, or in the <code>META.yml</code>. It will be displayed on the module’s cpan page as well.</p>

<pre code="bash">
$ curl -L http://search.cpan.org/dist/Git-CPAN-Patch/META.yml | \
    perl -MYAML -0 -E&#39;say Load(&#60;&#62;)-&#62;{resources}{repository}&#39;

git://github.com/yanick/git-cpan-patch.git
</pre><h4>&#60;singing name=”Adam West”&#62;Na na na na, Na na na na, GitPAN!&#60;/singing&#62;</h4>

<p>Thanks to <a href="http://search.cpan.org/~MSCHWERN/">Schwern</a>, all CPAN distributions now have a <a href="http://github.com">GitHub</a> repository tracking its releases. They can all be found under the GitHub <a href="http://github.com/gitpan">gitpan account</a>, and follow the pattern <a href="http://github.com/gitpan/Git-CPAN-Patch">http://github.com/gitpan/Git-CPAN-Patch</a>.</p>

<h4>Git::CPAN::Patch</h4>

<p>Speaking of <a href="http://search.cpan.org/dist/Git-CPAN-Patch">Git::CPAN::Patch</a>, you can use its set of scripts to ease the creation of CPAN-related git repositories. It also includes scripts to send patches directly from your local repository to a rt bug queue. </p>

