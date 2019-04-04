---
title: Fit To Be tied (tied handles and localized $\)
url: fit-to-be-tied
format: markdown
created: 2012-12-17
tags:
    - Perl
---

This one was going to be a cry for help and a request to confirm that I'm not
going cuckoo, but I think I figured it out. Still, for giggles, hear this:

I was playing around with one of my favorite Himalayan barbershop (*Galuga*, one
of those projects that just generate endless yak shaving) when I noticed
something funny with tied filehandles. After much head-scratching, I was able
to corner the problem with this small example:


    #syntax: perl
    use 5.10.0;

    use strict;
    use warnings;

    {
        package Foo;

        sub TIEHANDLE { return bless \my $i, shift; }

        sub PRINT { shift; $::X .= join '', @_, $\; } 

    }

    say "this is perl $]\n";

    print '>>>';
    print "nothing here-->";
    say   "but a CR there->";
    print "and nothing here->";
    print '<<<';

    tie *::FOO, 'Foo';

    print "\n\n";
    print FOO "nothing here-->";
    say   FOO "but a CR there->";
    print FOO "and nothing here->";
    print '>>>', $::X, '<<<';

    $\ = '';
    $::X = '';

    print "\n\n";
    print FOO "nothing here-->";
    say   FOO "but a CR there->";
    print FOO "and nothing here->";
    print '>>>', $::X, '<<<';

Basically, I define a package that will act like a filehandle. The `$\` used
in its `PRINT` is, according to [perltie](http://perldoc.perl.org/perltie.html), the magic way to make sure
`print` and `say` will both work: in the case of a `say`, `$\` will be
localized and assigned a carriage return.  Sounds good, no? But let's see what
happens when we run this baby:


    $ perl fit_to_be_tied.pl 
    this is perl 5.014002

    >>>nothing here-->but a CR there->
    and nothing here-><<<

    Use of uninitialized value $\ in join or string at tie.pl line 13.
    >>>nothing here-->but a CR there->
    and nothing here->
    <<<

    >>>nothing here-->but a CR there->
    and nothing here-><<<

The first stanza using *STDOUT* looks okay, but for the second stanza the
`print` after the `say` seems to cling to having `$\ = "\n"` even if it's not
supposed to. And to add a dash of *uh?* to the whole thing, if we set the
global '$\' not to be `undef` (as we do in the third stanza), all is fine
again.

Fortunately, and thanks to `perlbrew`, I have a perl 5.17.6 lying around, and
if I try the same test with it, I get:

    $ perl fit_to_be_tied.pl 
    this is perl 5.017006

    >>>nothing here-->but a CR there->
    and nothing here-><<<

    Use of uninitialized value $\ in join or string at tie.pl line 13.
    Use of uninitialized value $\ in join or string at tie.pl line 13.
    >>>nothing here-->but a CR there->
    and nothing here-><<<

    >>>nothing here-->but a CR there->
    and nothing here-><<<

Well, look at that. Everything's now behaving the way it should. I quickly
perused the perldeltas since 5.16.1 (where the issue can also be seen) but
didn't noticed any bug fix that could account for the change of behavior.
Well, even then I won't complain. I'll just have one more reason to way for
5.18.0 with bated breath...

