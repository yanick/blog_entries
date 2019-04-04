---
url: tmux-got-laziness
created: 2013-03-04
tags:
    - Perl
    - App::GitGot
---

# App::GitGot, tmux and Lotsa Laziness

In the last couple of days, I've been working on a new Dancer application.
Because it's using [Dancer2](cpan) and my brand-new, shiny and, err,
fairly buggy [Template::Caribou](cpan), I've found myself bouncing back
and forth between projects. So today I decided to take a few minutes to 
streamline my the yak shaving process.

## Got to have the right tools

First tool that I was already using (but nowhere often enough):
[App::GitGot](cpan), which herd your local Git repositories 
for you. Amongst other nifty commands, it has `chdir`, which opens
a subshell to any of those projects.

    #syntax: bash
    $ got list
    1) Catalyst-Plugin-VersionedURI    git   git@github.com:yanick/Catalyst-Plugin-VersionedURI.git
    2) Dancer                          git   git@github.com:yanick/Dancer.git
    3) Dancer-Plugin-Cache-CHI         git   git@github.com:yanick/Dancer-Plugin-Cache-CHI.git (Not checked out)
    4) Dancer-Plugin-Cache-CHI         git   git@github.com:yanick/Dancer-Plugin-Cache-CHI
    5) Dancer-Template-Declare         git   git://github.com/yanick/Dancer-Template-Declare.git
    6) Dancer2                         git   git@github.com:PerlDancer/Dancer2.git
    7) Dist-Zilla-PluginBundle-YANICK  git   git@github.com:yanick/Dist-Zilla-PluginBundle-YANICK.git
    8) GitStore                        git   git@github.com:yanick/perl-git-store.git
    9) GnuPG                           git   git@github.com:yanick/GnuPG.git
    10) Template-Caribou                git   git@github.com:yanick/Template-Caribou
    11) Term-Caca                       git   git@github.com:yanick/Term-Caca.git
    12) app-gitgot                      git   git@github.com:yanick/app-gitgot.git
    13) environment                     git   git@github.com:yanick/environment.git
    14) template-declare                git   git@github.com:yanick/template-declare.git

    $ got chdir Dancer

    $ pwd
    /home/yanick/work/perl-modules/dancer/Dancer

Neat, isn't? But, really, typing a *whole* distribution name to get there? This is
sooo exhausting. No, that simply won't do, so I [hacked][got-complete] a quick `got-complete` utility
script for my autocomplete pleasure.

## Move away chdir, tmux is in the house

I've heard of [tmux][tmux] before, but it's only yesterday that the dam
suddenly broke inside and the love began to pour in. 

You see, `got chdir` is
nice, but it's shells within shells. When I'm hacking on my application, I
typically hack on, realize that a library has a booboo, jump on that library
and do terrible things, return to the application, then probably return to the
library, and then patch a third set of modules just because I had a crazy
idea, and so on and so forth ad absurdum. The whole process is more like an
ever-widening madness gyre than a depth-first touch'n'go. What I need is
parallel shells, and `tmux` might be the answer.

Hence [the hacking][got-tmux] of a new `got` subcommand: `mux` (yes, I'm
amused by calling it `got mux`, but I was sane enough to
provide a `got tmux`. There's still hope for me). Instead of opening a
subshell, it opens a new tmux window or, if the window for that project is
already opened, jump to it.

Yeeees, this is beginning to take shape. But... `got mux`, that's awfully
long. Let's reduce that to a four-letter word, shall we?

    #syntax: bash
    complete -C got-complete -o nospace -o default hack
    alias hack='got mux'

There. Now I want to hack on Dancer? Then I do

    #syntax: bash
    $ hack Dancer

## Using Your Local Monsters

Of course, once you begin to mock with dependencies while you develop, you
have to begin to add them to your `perl` invocation, or stash them in
*PERL5LIB*. In my case, the project that began with

    #syntax: bash
    $ perl ./bin/app.pl

soon found itself requiring an amended `Template::Caribou`

    #syntax: bash
    $ perl -I ../perl-modules/Template-Caribou/lib ./bin/app.pl

then some shared modules with another project

    #syntax: bash
    $ perl -I ../perl-modules/Template-Caribou/lib  -I ../perl-modules/Galuga/lib ./bin/app.pl

Urgh. There should be a way to stash local paths for a project by doing
something like


    #syntax: bash
    $ devinc ../perl-modules/Template-Caribou/lib
    $ devinc Dancer-Plugin-Cache-CHI

and have them automatically stored in a file ready to be used to populate
*PERL5LIB*, like so

    #syntax: bash
    $ cat devlibs 
    export PERL5LIB=\
    ../perl-modules/Template-Caribou/lib:\
    /home/yanick/work/perl-modules/dancer/Dancer-Plugin-Cache-CHI/lib:\
    ;

    $ . devlibs 

    $ echo $PERL5LIB
    ../perl-modules/Template-Caribou/lib:/home/yanick/work/perl-modules/dancer/Dancer-Plugin-Cache-CHI/lib:

If you also think that could be handy, [rejoice][devinc].

## And a last cherry on the sundae...

We already have `hack`, how about also having a `tweak` to jump to a module
that need to be fixed, and automatically add it to the originator's `devlibs`?

    #syntax: bash
    # in your .bashrc
    complete -C got-complete -o nospace -o default tweak
    function tweak { devinc $1; hack $1; }

The result? Here, let me show you:

<div align="center">
<iframe width="560" height="315" src="http://www.youtube.com/embed/VHRD1RYKoc0" frameborder="0" allowfullscreen="allowfullscreen"></iframe>
</div>


[devinc]: https://github.com/yanick/environment/commit/fe505779173c694b715bf1f83f06cc9dd7696dd7
[got-tmux]: https://github.com/yanick/app-gitgot/tree/got-mux
[got-complete]: https://github.com/yanick/app-gitgot/tree/got-complete
[tmux]: http://tmux.sourceforge.net/

