---
title: ShareDir Without The Leftover Blues
url: sharedir-tarball
format: markdown
created: 18 Oct 2012
tags:
    - Perl
---

Sometimes, one needs to deploy non-Perl files alongside a distribution. For
that, we have [File::ShareDir](cpan) and its friends, which are lovely. But, alas, 
as the install of
the shared files follows the same rules as the installation of module files,
it has the same weakness: upon installation, CPAN clients will install files,
but won't remove any that aren't relevant anymore.

That means that if, for example, version 1.0 of the distribution was having

    share/foo
    share/bar

and version 1.1 changed that to 

    share/foo
    share/baz

then a user installing first version 1.0 then 1.1 will end up with 

    share/foo
    share/bar
    share/baz

which, depending of what you're using those files for, might be a problem.

## Let's be sneaky

Fortunately, there is a clever little
workaround in the case where you don't want the files of past distributions to
linger around. The trick is simple: bundle all the files to be shared into
a tarball called *shared-files.tar.gz*.  As there is now only that one file,
which name always remains the same, any new install is conveniently clobbering 
the old version. 

## But.. that's WORK!

Manually archiving the content of the *share* directory before any release is
no fun. So I wrote [Dist::Zilla::Plugin::ShareDir::Tarball](cpan) 
which, upon the file munging stage, gathers all 
files in the *share* directory and build the *shared-files.tar.gz* archive
with them.  If there is no such files, the process is simply skipped. 

Basically, adding this one plugin in the *dist.ini* of a project is all that
is required on the package generation side. On the other end, one will be able
to access that tarball the regular way:

    #syntax: perl
    use File::ShareDir qw/ dist_dir /;

    my $tarbar = dist_dir('My-Dist').'/'.'shared-files.tar.gz';

## So I have to extract the tarball? But... that's WORK!

... Seriously? 

Well, okay, fine, if there's something I can understand, it's laziness.
Which is why I also wrote [File::ShareDir::Tarball](cpan), which aims to
behave exactly like good ol' `File::ShareDir`, with the added magic that it'll
automatically extract the tarball for you, and return the path to the
resulting extracted directory. So all there is to do would be


    #syntax: perl
    use File::ShareDir::Tarball qw/ dist_dir /;

    my $dir = dist_dir('My-Dist');


For now, `File::Sharedir::Tarball` only accept `dist_dir()` because, well,
there's *Elementary* beginning in 10 minutes, but that's nothing I can't solve
the next 15 minutes I feel mildly bored.

In the meantime, enjoy. :-)
