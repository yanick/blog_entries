---
title: perl-achievements
url: perl-achievements
format: markdown
created: 19/Aug/2010
original: the Pythian Blog - http://www.pythian.com/news/15735/perl-achievements/
tags:
    - Perl
---

I already knew about
[git-achievements](http://github.com/icefox/git-achievements/) (and 
[partake in the fun](http://yanick.github.com/git-achievements/)).
But earlier this week [Dean](http://deanpearce.net/http://deanpearce.net/) showed me 
[Unit Testing Achievements](http://exogen.github.com/nose-achievements/).

My first thought after seeing it was: "cool, I want to port that to Smolder!". My second
thought was: "hey, if we can do it for Git, and for testing, why not for Perl
itself?"  [Perl::Critic](cpan) and [Perl::Tidy](cpan) already use 
[PPI](cpan) for their magic, surely it wouldn't be too hard to harness its
power for a little bit of fun?

And, indeed, it wasn't:

<pre code="bash">
[yanick@enkidu ~]$ cat foo.pl 
print "Hello world", $/;

[yanick@enkidu ~]$ alias perl="perl-achievements -r --"

[yanick@enkidu ~]$ perl foo.pl 
Congrats! You have unlocked 1 new achievement

************************************************************
*** Cryptomancer
*** Level 1

Used Perl magic variables.

Variables used: $/
************************************************************
Hello world

</pre>

The code for this new `Perl::Achievements`
[is on Github](http://github.com/yanick/Perl-Achievements).
For now I was only aiming at churning out a prototype, so
the code's a mess, there's no documentation whatsoever,
and there are only two achievements to unlock. *Buuut* if I have time,
and if it amuses peoples, it would be easy to make it grow into 
something a little more... interesting.
