---
title: got lib? Lieber Gott! 
url: got-lib
format: markdown
created: 2015-03-01
tags:
    - Perl
---

A new version of [got](cpan:release/App-GitGot) hit CPAN a few  days ago, and it has a brand new feature that is mind-bogglingly
awesome. Mind you, the fact that I'm the one who sent its PR might 
paint me as slightly biased on the matter. But let's not dwell too much
on the shameless self-promotion going on here, and instead let's turn our
gazes to that promised successor to sliced bread.

Before, though, a quick recap: `got` is a lovely little utility that 
help you manage your git repositories. At its core, it keeps a list of 
managed local git repositories and, upon request, will let you know of the 
status of each of them (dirty, all neatly commited locally, in sync with the 
remote origin) or update all the remote origins *en masse*.

That, by itself, is wonderful, but that core goodness comes  with even 
more delicious sprinkles: got can [open shells in specified
projects](https://metacpan.org/pod/App::GitGot::Command::chdir),
or open a [whole slew of them in tmux
windows](https://metacpan.org/pod/App::GitGot::Command::mux). It can also 
[fork stuff from GitHub](https://metacpan.org/pod/App::GitGot::Command::fork).
In short, it's growing to be a very nice repositories command center...

... and the growth just went one size bigger. You see, either at $work or on
my yak shaving expeditions, 
I tend to end up dealing with sizable codebases spanning many
repositories. Which means that a truckload of custom library paths
are usually required to get any of their scripts to work.

At first, of course, I went for the direct approach:

    $ perl -Ilib -I/and/this/other/lib -I../and/yet/another/lib bloody/script.pl

Then got annoyed with super-long commands, so stuffed all those libs in
`PERL5LIB`.

    # warning: this is fish, not bash
    $ set -x PERL5LIB lib /and/this/other/lib ../and/yet/another/lib

    $ perl bloody/script.pl


And then got fed up with remembering which bunch of libraries I need for this
project or that project, so I looked into [ylib](cpan:release/ylib) 
and [Devel::Local](cpan:release/Devel-Local). Truth to be told, they are
fairly good solutions. But I
thought that since `got` is already my repository shepherd, wouldn't it be
nice if it could take away even more of the humdrum of the library dance?

Well, thanks to `got tag` and `got lib`, it can. Lemme demonstrate. 

Let's say
that I try to run Galuga from a Dancer-less stock perlbrew install.

    15:26 yanick@enkidu ~/work/perl-modules/Galuga
    $ perl bin/app.pl
    Can't locate Dancer2.pm in @INC [...]

I'm missing Dancer2. And probably a bunch of plugins.  Very sad situation.
Fortunately, I have all
that I need in local repositories, which I had the good sense to tag as being
`dancer2`-related:

    $  got list --tag dancer2
    8) Dancer2                   git   git@github.com:PerlDancer/Dancer2.git
    9) Dancer2-Template-Caribou  git   git@github.com:yanick/Dancer2-Template-Caribou.git
    22) dancer2-plugin-feed       git   git@github.com:yanick/Dancer-Plugin-Feed.git

Cue in `got lib`, which will help me setting up that *PERL5LIB*. 

    # got lib can expand from a single repo
    $ got lib Web-Query/lib
    /home/yanick/work/perl-modules/Web-Query/lib

    # or from a whole tagged set
    $ got lib @dancer2/lib
    /home/yanick/work/perl-modules/dancer/Dancer2/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Template-Caribou/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Plugin-Feed/lib

    # or can pass a plain ol' directory through 
    $ got lib ./lib
    /home/yanick/work/perl-modules/Galuga/lib

    # all together now
    $ got lib Web-Query/lib @dancer2/lib ./lib
    /home/yanick/work/perl-modules/Web-Query/lib:/home/yanick/work/perl-modules/dancer/Dancer2/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Template-Caribou/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Plugin-Feed/lib:/home/yanick/work/perl-modules/Galuga/lib

Once we're happy, the list of library paths can be put in a `.gotlib` file to
be automatically picked by `got lib`.

    $ cat .gotlib
    ./lib
    @dancer2/lib
    Web-Query/lib

    $ got lib
    /home/yanick/work/perl-modules/Galuga/lib:/home/yanick/work/perl-modules/dancer/Dancer2/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Template-Caribou/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Plugin-Feed/lib:/home/yanick/work/perl-modules/Web-Query/lib

And, finally, we can use that to populate *PERL5LIB*.

    # using the 'fish' shell
    # for 'bash' you'll want 'export PERL5LIB=`got lib`'
    $ set -x PERL5LIB (got lib)

    # TADAH!
    $ perl bin/app.pl
    [ ... Dancer2 is found and everybody's happy ... ]


Being the lazy person I am, I can also let my shell do the work of doing all
that if a `.gotlib` file is present in the current directory:

    $ cat ~/.config/fish/functions/__got_lib.fish
    function __got_lib --on-variable PWD --description 'set got lib'

        status --is-command-substitution; and return

        test -f '.gotlib'; or return

        set -l mylib (got lib)
        echo "setting PERL5LIB to $mylib"

        set -x PERL5LIB $mylib
    end

    $ cd Galuga/
    setting PERL5LIB to /home/yanick/work/perl-modules/Galuga/lib:/home/yanick/work/perl-modules/dancer/Dancer2/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Template-Caribou/lib:/home/yanick/work/perl-modules/dancer/Dancer2-Plugin-Feed/lib:/home/yanick/work/perl-modules/Web-Query/lib

Neat, isn't?

Oh, and before I sign off this blog entry, a last note. You probably noticed
that the '/lib' subdirectories are explicitly given. That was a conscious
decision of mine. In part to allow for special cases (like adding
test-specific libs via `@dancer/t/lib`), but also to keep the door open for
`got lib` to be used for non-Perl projects. I won't go into details here, but
just to give you a teaser... say you are in a repo building `.so` files that you
want to append to your `LD_LIBRARY_PATH`. Then this will do the trick:

    
    $ echo $LD_LIBRARY_PATH
    /usr/kde/3.5/lib /usr/kde/3.5/lib

    $ set -x LD_LIBRARY_PATH  ( got lib --libvar LD_LIBRARY_PATH ./build/ )

    $ echo $LD_LIBRARY_PATH
    /home/yanick/work/perl-modules/Galuga/build:/usr/kde/3.5/lib


Enjoy!






