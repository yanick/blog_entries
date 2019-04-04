---
original: the Pythian blog - http://www.pythian.com/news/7069/local-pod-browsing-using-podpomweb-via-the-cli
url: local-pod-browsing-using-podpomweb-via-the-cli
created: 11 Jan 2010
tags:
    - Perl
    - Pod
---

# Local POD browsing -- using Pod::POM::Web via the CLI

<p>Half the time I want to peek at the doc of a module, I hit <tt>perldoc</tt>.  The rest of the time I type <em>cpan Some::Module</em><sup><a href="#note" name="note-src">[1]</a></sup> in Firefox and read the POD straight out of CPAN.  And while it’s pretty and handy, it also feels kinda silly to go on a remote server to read documentation that is also sitting on my computer. Surely, I tell myself, there must be a better way.</p>

<p>Cue in the several Perl modules that act as local POD web servers.  After giving a few of them a quick test-run, I decided to give <a href="http://search.cpan.org/~dami/Pod-POM-Web/">Pod::POM::Web</a> a try. Being a CLI jockey, I wanted to be able to open the POD of a module from the command line.  Not a problem, I just had to create the script ‘pod’:</p>

<pre code="bash">
#!/bin/bash

POD_PORT=8787

perl -MPod::POM::Web -e&#34;Pod::POM::Web-&#62;server($POD_PORT)&#34; 2&#62; /dev/null &#38;

PAGE=`perl -e&#39;s(::)(/)g for @ARGV; print @ARGV&#39; $1`

HOSTNAME=`hostname`

kfmclient openURL &#34;http://${HOSTNAME}:$POD_PORT/$PAGE&#34;;
</pre>

<p>There is not even a need to fire up the Pod::POM::Web server beforehand: the script will do it for us (if the server is already running, subsequent calls to <code>pod</code> will harmlessly try to start a new server on the same port and fail).  It should be noted that ‘kfmclient’ is <a href="http://www.kde.org/">KDE</a>-specific — for any other desktop environment, you might want to change that to a direct call to <code>firefox</code>.</p>

<p>It’s already not too shabby, but wouldn’t it be even better with a little bit of auto-completeness magic?  To do that, we need a short script, <tt>pod_complete</tt>:</p>

<pre code="perl">
#!/usr/bin/perl

use 5.010;

use List::MoreUtils qw/ uniq /;

my ( $sofar ) = reverse split &#39; &#39;, $ENV{COMP_LINE};

$sofar =~ s(::)(/)g;

my ( $path, $file ) = $sofar =~ m!^(.*/)?(.*)?$!;

my @dirs = map { $_.&#39;/&#39;.$path } @INC;

my @candidates;

for ( @dirs ) {
    opendir my $dir, $_;
    push @candidates, grep { /^\Q$file/ } grep { !/^\.\.?$/ } readdir $dir;
}

if ( $path ) {
    $_ = $path.&#39;/&#39;.$_ for @candidates;
}

s/\.pm$// for @candidates;
s(/+)(/)g for @candidates;

say for uniq @candidates;
</pre>

<p>All that is left is to add . . . </p>

<pre code="bash">
complete -C pod_complete pod
</pre>

<p> . . . to our <code>bashrc</code>, and it should all work (with the caveat that the modules must be entered as <code>Some/Module</code> instead of <code>Some::Module</code>).</p>

<pre code="bash">
$ pod XML/XPath
XML/XPath        XML/XPathScript
</pre>

<p><a href="#note-src" name="note">[1] </a>If you don’t already know the trick: create a bookmark with keyword ‘cpan’ and location <a href="http://search.cpan.org/search?query=%s">http://search.cpan.org/search?query=%s</a>.</p>

