---
title: dpanneur – your friendly DarkPAN/CPAN proxy corner store
url: dpanneur-your-friendly-darkpancpan-proxy-corner-store
original: the Pythian blog - http://www.pythian.com/news/9389/dpanneur-your-friendly-darkpancpan-proxy-corner-store
created: 2010-03-15
tags:
    - cache
    - CPAN
    - darkpan
    - Git
    - mirror
    - Perl
    - proxy
---

<div style="font-size: small;float: right;margin: 15px"><a
href="http://www.flickr.com/photos/21253803@N06/" rel="cc:attributionURL"><img
alt="dépanneur" src="__ENTRY_DIR__/depanneur.jpg" width="250" /></a><br /><a href="http://creativecommons.org/licenses/by-nc-sa/2.0/" rel="license">CC BY-NC-SA 2.0</a></div>

<p>There were two things I have wanted to do for some time now. The first was to come up with a way to quickly and easily set up a DarkPAN mirror so that we would have more control over our dependency chain at work. The second was to make a portable CPAN proxy service, so that I can always have access to my favorite modules, even if the machine I’m working on has no Internet access. Last week, I finally had a few ‘rount tuits’ to spend on this type of background itch, and the result is <a href="http://github.com/yanick/dpanneur">dpanneur</a> (for <em>dépanneur</em>, French Canadian for <em>convenience store</em>).</p>

<p><strong>Installation</strong></p>

<p>As it stands, <em>dpanneur</em> is a very thin Catalyst application gluing together the goodiness of <a href="http://search.cpan.org/dist/CPAN-Cache">CPAN::Cache</a> and <a href="http://search.cpan.orgl/dist/MyCPAN-App-DPAN">MyCPAN::App::DPAN</a>, and throwing in Git as the archive manager.</p>

<p>To get it running, first fetch it from Github</p>

<pre code="bash">
$ git clone git://github.com/yanick/dpanneur.git
</pre>

<p>then check that you have all the dependencies</p>

<pre code="bash">
$ perl Makefile.PL
</pre>

<p>and run the script that will create the module repository</p>

<pre code="bash">
$ ./script/create_repo
</pre>

<p>For now, the module repository is hard-coded to be in the subdirectory <em>cpan</em> of <em>dpanneur</em>. A branch called <em>proxy</em> is created and checked out. Eventually, I’ll use GitStore to push newly fetched modules to the repository, but for the time being if <em>dpanneur</em> is to be used as a proxy, that branch must remain as the one being checked out.</p>

<p>All that is left is to fire up the server in whichever mode you prefer (single-thread test server would do nicely for now)</p>

<pre code="bash">
$ ./script/dpanneur_server.pl
</pre>

<p>and there you are, running your first dpanneur. Congrats! :-)</p>

<p><strong>Using it as a caching proxy</strong></p>

<p>You can use the server as a caching proxy, either for its own sake, or to seed the DarkPAN branches. To do that, you just have to configure your CPAN client to use <em>http://yourmachine:3000/proxy</em>:</p>

<pre code="bash">
$ cpan
cpan[1]&#62; o conf urllist = http://localhost:3000/proxy
cpan[2]&#62; reload index
cpan[3]&#62; install Acme::EyeDrops
Running install for module &#39;Acme::EyeDrops&#39;
Running make for A/AS/ASAVIGE/Acme-EyeDrops-1.55.tar.gz
Fetching with LWP:
    http://localhost:3000/proxy/authors/id/A/AS/ASAVIGE/Acme-EyeDrops-1.55.tar.gz
etc..
</pre>

<p>As the modules are downloaded, they are also saved and committed within the repo</p>

<pre code="bash">
[dpanneur]$ cd cpan

[cpan (proxy)]$ git log -n 3
commit d065ad152f2204295334c5475104a3da517b6ae1
Author: Yanick Champoux &#60;yanick@babyl.dyndns.org&#62;
Date:   Wed Mar 10 20:32:52 2010 -0500

    authors/id/A/AS/ASAVIGE/Acme-EyeDrops-1.55.tar.gz

commit e8d2e83d1b16e2e0713d125f9a4bd2742681f859
Author: Yanick Champoux &#60;yanick@babyl.dyndns.org&#62;

Date:   Wed Mar 10 20:31:42 2010 -0500

    authors/id/D/DC/DCONWAY/Acme-Bleach-1.12.tar.gz

commit 7e0b4b600bac8424c519199ee96dc56ffbb177eb
Author: Yanick Champoux &#60;yanick@babyl.dyndns.org&#62;
Date:   Wed Mar 10 20:30:47 2010 -0500

    modules/03modlist.data.gz
</pre>

<p><strong>Using it as a DarkPAN server</strong></p>

<p>There is not much more involved to enabling DarkPAN repos. All we have to do is to create a branch with the modules we want and have the ‘dpan’ utility bundled with MyCPAN::App::DPAN generate the right files for us.</p>

<p>To continue with the example of the previous section, let’s say that we want a DarkPAN branch containing Acme::EyeDrops, but not Acme::Bleach. Then we’d do</p>

<pre code="bash">
                        # only necessary if you are running
                        # the server while you work on the branch
[dpanneur]$ git clone cpan cpan-work   

[dpanneur]$ cd cpan-work

                        # branch just before we imported Acme::Bleach
[cpan-work (proxy)]$ git branch pictoral 7e0b4b600bac8424c519199ee96dc56ffbb177eb

[cpan-work (proxy)]$ git checkout pictoral
Switched to branch &#39;pictoral&#39;

                        # cherry-pick the Acme::EyeDrops commit
[cpan-work (pictoral)]$ git cherry-pick d065ad152f2204295334c5475104a3da517b6ae1

                        # rebuild the module list
[cpan-work (pictoral)]$ dpan

                        # commit the new 02packages.details.txt.gz
[cpan-work (pictoral)]$ git add .
[cpan-work (pictoral)]$ git commit -m &#34;dpan processing&#34;

                        # push back to the mothership
[cpan-work (pictoral)]$ git push origin pictoral
</pre>

<p>And that’s it. Now point the cpan client to <em>http://yourmachine:3000/pictoral</em>, and you’ll get the limited mirror.</p>

<pre code="bash">
cpan[1]&#62; o conf urllist http://localhost:3000/pictoral
cpan[2]&#62; reload index

cpan[3]&#62; i Acme::EyeDrops
Strange distribution name [Acme::EyeDrops]
Module id = Acme::EyeDrops
    CPAN_USERID  ASAVIGE (Andrew J. Savige &lt;asavige@cpan.org&#62;)
    CPAN_VERSION 1.55
    CPAN_FILE    A/AS/ASAVIGE/Acme-EyeDrops-1.55.tar.gz
    UPLOAD_DATE  2008-12-02
    MANPAGE      Acme::EyeDrops - Visual Programming in Perl
    INST_FILE    /usr/local/share/perl/5.10.0/Acme/EyeDrops.pm
    INST_VERSION 1.55

cpan[4]&#62; i Acme::Bleach
Strange distribution name [Acme::Bleach]
No objects found of any type for argument Acme::Bleach
</pre>
