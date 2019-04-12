---
title: Git's the nightclub, Perltidy's the bouncer
format: html
created: 2008-02-09
original: use.perl.org - http://use.perl.org/~Yanick/journal/35626
tags:
    - Perl
    - Git
    - Perl::Tidy
---

<p>
I finally wrapped my CVS-encrusted mind
around Git's hooks. Huzzah! The biggest hurdle, really, was
realizing that there is no spoon. </p><p>
Anyway, as I'm an unsalvageable slob who always
forget to run perltidy before committing changes, I've
written a <code>pre-commit</code> hook that makes sure that
all Perl files to be committed are all clean, neat and tidy
(and aborts the commit and chides me if they are not):</p><blockquote><div><p>
<pre>#!/usr/bin/perl
 
use Perl6::Slurp;
 
my $status = slurp '-|', 'git-status';
 
# only want what is going to be commited
$status =~ s/Changed but not updated.*$//s;
 
my @dirty =
  grep { !file_is_tidy($_) }                   # not tidy
  grep {<nobr> <wbr></wbr></nobr>/\.(pl|pod|pm|t)$/ }                  # perl file
  map  {<nobr> <wbr></wbr></nobr>/(?:modified|new file):\s+(\S+)/ }    # to be commited
  split "\n", $status;
 
exit 0 unless @dirty;                          # Alles gut
 
warn "following files are not tidy, aborting commit\n",
     map "\t$_\n" => @dirty;
 
exit 1;
 
### utility functions ###############################################
 
sub file_is_tidy {
    my $file = shift;
 
    my $original = slurp $file;
    my $tidied = slurp '-|', 'perltidy', $file, '-st';
 
    return $original eq $tidied;
}</pre></p></div> </blockquote>
