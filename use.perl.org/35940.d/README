---
title: per(l)version
format: html
created: 2008-03-19
original: use.perl.org - http://use.perl.org/~Yanick/journal/35940
tags:
    - Perl
---

<p>
Updating the version number is all the files of a module
distribution is a pain in the behind.  It's repetitive,
boring and ridiculously prone to errors -- in short,  a task
fit for a script, not for humans.  So I decided to hack myself
a little something, for the time being called <i>perversion</i>,
to take care of it.  </p><p>

The idea is pretty straight-forward. In the root directory of my
distribution, I have a config file named <i>perversionrc</i>
that contains Perl code that return an hash of all files
where the the module version is given, and regular expressions
to capture the said version.  For example, here's the
<i>perversionrc</i> of WWW::Ohloh::API:</p><blockquote><div><p> <pre>use File::Find::Rule;
 
my %file;
 
$file{README} = qr/WWW-Ohloh-API version (\S+)/;
 
for my $m ( File::Find::Rule->file->name( '*.pm' )->in( 'lib' ) ) {
   $file{$m} = [ qr/\$VERSION\s*=\s*'(.*?)';/,
                 qr/This document describes \S+ version (\S*)/ ];
}
 
%file;</pre></p></div> </blockquote><p>
Once that file is present, <i>perversion</i> is ready to rock.  You want to
verify that the version number is consistent in all given
files?</p><blockquote><div><p> <pre>$ perversion
distribution version is set to 0.0.9
lib/WWW/Ohloh/API/Enlistment.pm:12: 0.0.6
!!! does not match distribution version (0.0.9) !!!
lib/WWW/Ohloh/API/Repository.pm:10: 0.0.6
!!! does not match distribution version (0.0.9) !!!
lib/WWW/Ohloh/API/ContributorLanguageFact.pm:10: 0.0.6
!!! does not match distribution version (0.0.9) !!!
lib/WWW/Ohloh/API/ContributorFact.pm:10: 0.0.6
!!! does not match distribution version (0.0.9) !!!
lib/WWW/Ohloh/API/ContributorFact.pm:241: 0.0.6
!!! does not match distribution version (0.0.9) !!!</pre></p></div>
</blockquote><p>Want to set the version to a specific
value?</p><blockquote><div><p> <pre>$ perversion -set 1.2.3
changing all versions to 1.2.3..
        updating lib/WWW/Ohloh/API.pm..
        updating lib/WWW/Ohloh/API/Language.pm..
        updating lib/WWW/Ohloh/API/ActivityFacts.pm..
        updating lib/WWW/Ohloh/API/Account.pm..
        updating lib/WWW/Ohloh/API/Kudos.pm..
        updating lib/WWW/Ohloh/API/Project.pm..
        updating lib/WWW/Ohloh/API/Enlistment.pm..
        updating lib/WWW/Ohloh/API/KudoScore.pm..
        updating lib/WWW/Ohloh/API/Factoid.pm..
        updating lib/WWW/Ohloh/API/Repository.pm..
        updating lib/WWW/Ohloh/API/Projects.pm..
        updating lib/WWW/Ohloh/API/ContributorLanguageFact.pm..
        updating lib/WWW/Ohloh/API/Languages.pm..
        updating lib/WWW/Ohloh/API/ActivityFact.pm..
        updating lib/WWW/Ohloh/API/ContributorFact.pm..
        updating lib/WWW/Ohloh/API/Analysis.pm..
        updating lib/WWW/Ohloh/API/Kudo.pm..
        updating README..
done</pre></p></div> </blockquote><p>Don't want to go through the mental challenge of computing the
next version yourself? No problem!</p><blockquote><div><p> <pre>$ perversion -inc revision
distribution version is set to 1.2.3
new distribution version is 1.2.4
 
$ perversion -inc minor
distribution version is set to 1.2.4
new distribution version is 1.3.0
 
$ perversion -inc major
distribution version is set to 1.3.0
new distribution version is 2.0.0
 
$ perversion -inc alpha
distribution version is set to 2.0.0
new distribution version is 2.0_1</pre></p></div> </blockquote><p>
The script is still raw and in need of polishing,
but for those interested, it's available from its
very own <a href="http://babyl.dyndns.org/git/?p=perversion.git" rel="nofollow">
git repository</a>.
</p>
