---
title: Distributing Dancer Apps as Modules
url: dancer-local
format: markdown
created: 12 Sep 2012
tags:
    - Perl
    - Dancer
---

Something that has been bugging me for a long time is how [Dancer](cpan) 
apps (or [Catalyst](http://search.cpan.org/~jjnapiork/Catalyst-Runtime-5.90016/) apps for what matters) can't, generally-speaking, be installed like regular
modules or applications because of their configuration files, static files and
whatnots. What I would dearly love is to be able to do

    #syntax: bash
    $ cpanm App::Chorus
    $ chorus.pl prez.mkd

and have stuff, y'know, just work. (If you wonder what Chorus is, look [here](http://babyl.dyndns.org/techblog/entry/chorus))

So I decided it was high time to try and have a stab at a potential solution.

The mad scheme I came up with is based on two tricks. The first one is
[File::ShareDir](cpan), to install all the templates, configs and other
files required by the app alongside the distribution. The second one is 
to use the `my_dist_data` function of [File::HomeDir](cpan) to copy
all those goodies in a user-specific location (because we don't want users to
compete and clobber each other). For them to work together, we'll need to
tweak our Dancer app files a little bit, and
we'll need a small dash of magic called `Dancer::Local`.

## Grooming the Application

Let's assume that we are starting with a typical Dancer app called `Foo`.
First thing to do to make it installable is a no-brainer: rename the default
script from `app.pl` to `foo.pl`. The script itself will have to be modified
to use `Dancer::Local`:

    #syntax: perl
    #!/usr/bin/env perl

    # important: must be before 'use Dancer'
    use Dancer::Local 'Foo';

    use Dancer;

    use Foo;
    dance;

Although that's not quite true. We could also leave the script alone and just
latter call it as

    #syntax: bash
    $ perl -IDancer::Local=Foo `which foo.pl`

But that's not as appealing, so let's not do that unless we are forced to.

The last step (yes, already!) consists of adding the
`File::ShareDir` support to the building process. I prefer
[Module::Build](cpan) over [ExtUtils::MakeMaker](cpan), so I went
with:

    #syntax: perl
    package MyBuild;

    use strict; 
    use warnings;

    use base qw/ Module::Build /;

    use File::Copy::Recursive qw/ rcopy /;

    $File::Copy::Recursive::CPRFComp = 1;

    my @to_copy = qw/
        config.yml
        logs
        environments
        public
        views
        REMOVE_ME
    /;

    unless ( -d 'share' ) {
        mkdir 'share';

        rcopy( $_, 'share' ) for grep { -e $_ } @to_copy;
    }

    1;

Mind you, I could have just thrown all the files in `share` in the first
place, but as I'm the type of guy who wants his cake and munch on it too, I
wanted to keep the default layout as close as possible to what
already exist. The eagle-eyed might also have noticed the mysterious
*REMOVE_ME* file. More details on that in a few paragraphs.

And our distribution is now ready to be installed. 

## Dancer::Local, aka the Man Behind the Curtain

What we did so far is to ensure that if the application is installed, it is
installed with all its components. Now we need a little helping elf to make
sure that the app knows how to find and use those components, wherever it's
called from. That'll be the job of `Dancer::Local`:

    #syntax: perl
    package Dancer::Local;

    use 5.10.0;

    use strict;
    use warnings;

    use File::ShareDir 'dist_dir';
    use File::HomeDir;
    use File::Copy::Recursive qw/ dircopy /;
    use File::Path qw/ make_path /;
    use List::MoreUtils qw/ after_incl /;

    sub import {
        my( $self, $dist ) = @_;

        my $appdir;

        if ( my @to_install = after_incl { $_ eq '--install' } @ARGV ) {
            make_path( $to_install[1] ) if defined $to_install[1];

            $appdir = $to_install[1] // '.';

            dircopy( dist_dir($dist) => $appdir );

            say "installed shared file for '$dist' in '$appdir'";
        }
        else {
            no warnings 'uninitialized';

            $appdir = $ENV{DANCER_APPDIR} 
                || ( '.' x -f 'config.yml' )
                || File::HomeDir->my_dist_data($dist) 
                || create_local_copy($dist);
        }

        $ENV{DANCER_APPDIR} = $appdir;

        if ( open my $fh, "$appdir/REMOVE_ME" ) {
            say "\n", <$fh>, "\n", 
                "*** review the configuration files in '$appdir'\n",
                "*** delete '$appdir/REMOVE_ME',\n",
                "*** and run $0 again\n";

            exit;
        }

        say "running $dist from $appdir...";
    }

    sub create_local_copy {
        my $dist = shift;

        my $local_copy = File::HomeDir->my_dist_data($dist,{create=>1});

        print "copying $dist app files to $local_copy...\n";

        dircopy( dist_dir($dist) => $local_copy );

        return $local_copy;
    }

    1;


The module is short, but does a lotsa things. Namely:

* if the script is called with the `--install` option, it'll make a copy of
the distribution share directory to the specified location (or the current
directory, if no location was given) and assume that location to be the root
directory of the app.

* If the environment variable *DANCER_APPDIR* is defined, it assumes the user
already know what she's doing and will leave things as-is.

* If not, it'll check if the current directory has a `config.yml`, and if it
does, take it as root directory.

* If not, it will use the user-specific directory given by
`File::HomeDir::my_dist_data()` as the root directory of the app, populating
it on the fly if it doesn't already exist.

* After all that, if it finds a file called 'REMOVE_ME' in the app root dir,
it'll stop and require the user to delete it before allowing the application
to start (which is meant to help for the cases where the app won't work without configuration
changes).

And, so far, there's all there is to it. Strangely, it seems to work and take
care of the most common cases. The code for 
`Dancer::Local` 
lives in the usual [Github](https://github.com/yanick/Dancer-Local) spot. But
before I send it CPANward, I have to ask the question:
am I unto something, or I am off my ever-elusive rockers?
