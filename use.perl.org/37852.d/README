---
format: html
created: 2008-11-11
original: use.perl.org - http://use.perl.org/~Yanick/journal/37852
tags:
    - Perl
    - Dist::Release
---

# introducing Dist::Release

<p>(<i>cross-posted from
<a href="http://babyl.dyndns.org/techblog" rel="nofollow">Hacking Thy Fearful Symmetry</a> </i>)
</p><p>I know, I know, there's already more module release managers out there
than there are Elvis impersonators in Vegas.  Still, module releasing
seems to
be a very personal kind of itch, and like so many before
I couldn't resist and
came up with my very own scratching stick.</p><p>Of course, I've tried Module::Release.  But, although
it is intended to be customized to suit each author's specific needs,
one has to dig fairly deep in the module's guts to do so.  What I
really wanted was something even more plug'n'play, something that would
be brain-dead easy to plop new components in.  Hence Dist::Release.</p><p>In Dist::Release, the release process is seen as a sequence of steps.
There are two different kind of steps: checks and actions.
Checks are non-intrusive verifications (i.e., they're
not supposed to touch anything), and actions are the steps
that do the active part of the release.  When one launches
a release, checks are done first.  If some fail, we abort the process.
If they all pass, then we are good to go and the actions are done as well. </p><p>







<b>Implementing a check</b>
</p><div><p>To create a check, all that is needed is one module with a 'check' method.
For example, here is the code to verify that the distribution's MANIFEST
is up-to-date:</p><blockquote><div><p> <pre>&#xA0; &#xA0; package Dist::Release::Check::Manifest::Build;
 
&#xA0; &#xA0; use Moose;
 
&#xA0; &#xA0; use IPC::Cmd 'run';
 
&#xA0; &#xA0; extends 'Dist::Release::Step';
 
&#xA0; &#xA0; sub check {
&#xA0; &#xA0; &#xA0; &#xA0; my $self = shift;
 
&#xA0; &#xA0; &#xA0; &#xA0; $self-&gt;diag( q{running 'Build distcheck'} )
 
&#xA0; &#xA0; &#xA0; &#xA0; my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
&#xA0; &#xA0; &#xA0; &#xA0; run( command =&gt; [qw#<nobr> <wbr/></nobr>./Build distcheck #] );
 
&#xA0; &#xA0; &#xA0; &#xA0; return $self-&gt;error( join '', @$full_buf )
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; if not $success or grep<nobr> <wbr/></nobr>/not in sync/ =&gt; @$stderr_buf;
&#xA0; &#xA0; }
 
&#xA0; &#xA0; 1;</pre></p></div> </blockquote><p>Dist::Release  considers the check to have failed if there is any call made
to <code>error()</code>.  If there is no complain, then it assumes that everything is
peachy.</p></div><p>
<b>Implementing an action</b>
</p><div><p>Actions are only marginally more complicated than checks.  The module
implementing the action can have an optional <code>check()</code> method, which is
going to be run with all the other checks, and must have a <code>release()</code>,
which make the release-related changes.</p><p>For example, here's the
CPANUpload action:</p><blockquote><div><p> <pre>&#xA0; &#xA0; package
Dist::Release::Action::CPANUpload;
 
&#xA0; &#xA0; use Moose;


&#xA0; &#xA0; use CPAN::Uploader;
 
&#xA0; &#xA0; extends
'Dist::Release::Action';
 
&#xA0; &#xA0; sub check {
&#xA0; &#xA0; &#xA0; &#xA0; my
($self) = @_;
 
&#xA0; &#xA0; &#xA0; &#xA0; # do we have a pause id?
&#xA0; &#xA0; &#xA0;
&#xA0; unless ($self-&gt;distrel-&gt;config-&gt;{pause}{id}
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; and
$self-&gt;distrel-&gt;config-&gt;{pause}{password} ) {
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0;
$self-&gt;error('pause id or password missing from config file');
&#xA0; &#xA0; &#xA0; &#xA0;
}
&#xA0; &#xA0; }
 
&#xA0; &#xA0; sub release {
&#xA0; &#xA0; &#xA0; &#xA0; my $self =
shift;
 
&#xA0; &#xA0; &#xA0; &#xA0; $self-&gt;diag('verifying that the tarball is
present');
 
&#xA0; &#xA0; &#xA0; &#xA0; my @archives = &lt;*.tar.gz&gt; or return $self-&gt;error('no tarball found');
 
&#xA0; &#xA0; &#xA0; &#xA0; if ( @archives &gt; 1 ) {
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; return $self-&gt;error( 'more than one tarball file found: ' . join ',',
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; @archives );
&#xA0; &#xA0; &#xA0; &#xA0; }
 
&#xA0; &#xA0; &#xA0; &#xA0; my $tarball = $archives[0];
 
&#xA0; &#xA0; &#xA0; &#xA0; $self-&gt;diag("found tarball: $tarball");
 
&#xA0; &#xA0; &#xA0; &#xA0; $self-&gt;diag("uploading tarball '$tarball' to CPAN");
 
&#xA0; &#xA0; &#xA0; &#xA0; my ( $id, $password ) =
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; map { $self-&gt;distrel-&gt;config-&gt;{pause}{$_} } qw/ id password<nobr> <wbr/></nobr>/;
 
&#xA0; &#xA0; &#xA0; &#xA0; $self-&gt;diag("using user '$id'");
 
&#xA0; &#xA0; &#xA0; &#xA0; my $args = { user =&gt; $id, password =&gt; $password };
 
&#xA0; &#xA0; &#xA0; &#xA0; unless ( $self-&gt;distrel-&gt;pretend ) {
&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; CPAN::Uploader-&gt;upload_file( $tarball, $args );
&#xA0; &#xA0; &#xA0; &#xA0; }
&#xA0; &#xA0; }
 
&#xA0; &#xA0; 1;</pre></p></div> </blockquote><p>As for the <code>check()</code>, Dist::Release figures out that a <code>release()</code> failed
if there's a call to <code>error()</code>.  </p></div><p>
<b>Configuring for a module</b>
</p><div><p>Configuration is done via a 'distrelease.yml' file dropped in the root
directory of the project.  The file looks like this:</p><blockquote><div><p>
<pre>&#xA0; &#xA0; pause:
&#xA0; &#xA0; &#xA0; &#xA0; id: yanick
&#xA0; &#xA0; &#xA0; &#xA0; password: hush
&#xA0; &#xA0; checks:
&#xA0; &#xA0; &#xA0; &#xA0; - VCS::WorkingDirClean
&#xA0; &#xA0; &#xA0; &#xA0; - Manifest
&#xA0; &#xA0; actions:
&#xA0; &#xA0; &#xA0; &#xA0; - GenerateDistribution
&#xA0; &#xA0; &#xA0; &#xA0; - CPANUpload
&#xA0; &#xA0; &#xA0; &#xA0; - Github</pre></p></div> </blockquote><p>It's pretty self-explanatory.  The checks and actions are applied in the order
they are given in the file.</p></div><p>
<b>Crying havoc...</b>
</p>
<div>
<p>And once the configuration file is present, all that remains to be done is to run <code>distrelease</code>, sit back and enjoy the show:</p><blockquote><div><p> 

<pre>
$ distrelease 
Dist::Release will only pretend to perform the actions (use --doit for the real deal)
&#xA0;   running check cycle...
&#xA0; &#xA0; regular checks
&#xA0; &#xA0; VCS::WorkingDirClean&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; [failed]
&#xA0; &#xA0; working directory is not clean
&#xA0; &#xA0; # On branch master
&#xA0; &#xA0; # Changed but not updated:
&#xA0; &#xA0; #&#xA0; &#xA0;(use "git add &lt;file&gt;..." to update what will be committed)
&#xA0; &#xA0; #
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;Build.PL
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;Changes
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;README
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;distrelease.yml
  &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;lib/Dist/Release/Check/Manifest.pm
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;modified:&#xA0; &#xA0;script/distrelease
&#xA0; &#xA0; #
&#xA0; &#xA0; # Untracked files:
&#xA0; &#xA0; #&#xA0; &#xA0;(use "git add &lt;file&gt;..." to include in what will be committed)
  &#xA0; #
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;STDOUT
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;a
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;blog
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;xml
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;xt/dependencies.t
&#xA0; &#xA0; #&#xA0; &#xA0; &#xA0; &#xA0;xxx
&#xA0; &#xA0; no changes added to commit (use "git add" and/or "git commit -a")
&#xA0; &#xA0; Manifest&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; [failed]
&#xA0; &#xA0; No such file: lib/Dist/Release/Action/DoSomething.pm
&#xA0; &#xA0; Not in MANIFEST: a
&#xA0; &#xA0; Not in MANIFEST: blog
&#xA0; &#xA0; Not in MANIFEST: lib/Dist/Release/Action/Github.pm
&#xA0; &#xA0; Not in MANIFEST: STDOUT
&#xA0; &#xA0; Not in MANIFEST: xml
&#xA0; &#xA0; Not in MANIFEST: xt/dependencies.t
&#xA0; &#xA0; Not in MANIFEST: xxx
&#xA0; &#xA0; MANIFEST appears to be out of sync with the distribution
&#xA0; &#xA0; pre-action checks
&#xA0; &#xA0; GenerateDistribution&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; [passed]
&#xA0; &#xA0; no check implemented
&#xA0; &#xA0; CPANUpload&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; [passed]
&#xA0; &#xA0; Github&#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; &#xA0; [passed]
&#xA0; &#xA0; 2 checks failed
&#xA0; &#xA0; some checks failed, aborting the release</pre>
</p></div> </blockquote></div><p>
<b>Getting the good</b>
</p><div><p>A <a href="http://search.cpan.org/dist/Dist-Release/" rel="nofollow">first release of Dist::Release</a>
is already waiting for you on CPAN.  It's beta, has no documentation, is
probably buggy as hell, but it's there.  And the code is also available on
<a href="http://github.com/yanick/dist-release/tree/master" rel="nofollow">Github</a>.  Comments,
suggestions, forks and patches are welcome, as always.</p>
<p>:-)</p></div>
