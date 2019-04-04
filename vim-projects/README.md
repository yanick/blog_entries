---
title: Fine-Tuning the 'vim-project' Plugin For My Perl Needs
url: vim-project
format: markdown
created: 2012-10-14
tags:
    - Perl
    - Vim
---

I'm a [vim][vim] man. Sure, from time to time I hit mid-line editing crisis and
feel the need to go and try out some other more flashy editors. But, so far,
I've always returned to dear ol' Vim.

Of course, when it comes to hacking code, it comes handy when the editor can
also give you a view of the overall project. To browse directories, I'm using
the [NERD Tree](https://github.com/scrooloose/nerdtree). But I also like to
have a view where I can move files around in the listing, organize them in
categories and hide a few of them. For that, there's [vim
project](http://www.vim.org/scripts/script.php?script_id=69). It's cool, it's
nifty, it's... almost what I want. Because, you see, refreshing
your view throw away all manual changes, so the user is caught between adding
new files manually (booh!), or having to reorganize things each time 'refresh'
it hit (gah!).

Obviously, something has to be done about that. What I did is to create a 
small script, [gen_pvim.pl](https://github.com/yanick/environment/blob/master/bin/gen_pvim), 
which update a `project.vim` with new files (and new ignores), or create a
skeleton one where none is present:

    #syntax: bash
    $ gen_pvim
    Dancer-Plugin-MobileDevice=/home/yanick/work/perl-modules/Dancer-Plugin-MobileDevice CD=. {

    lib/                 Files=lib {
    Dancer/Plugin/MobileDevice.pm
    }
    t/                   Files=t {
    01-is-mobile-device.t
    boilerplate.t
    pod-coverage.t
    manifest.t
    03-dynamic-layout.t
    02-tokens.t
    00-load.t
    logs/development.log
    pod.t
    views/layouts/main.tt
    views/layouts/mobile.tt
    views/index.tt
    }
    distro               Files=. {
    MANIFEST
    .gitignore
    Changes
    Makefile.PL
    MANIFEST.SKIP
    ignore.txt
    README
    }
    # \.git
    }

When updating a `project.vim` file, this script will insert any new file (in
the right folder, natch), and will take any comment as regex for files that
must be ignored. For bonus points, the ignore filters are localised to their
folder and their descendants.

As the final touch, I
[slightly modified 'vim
project'](https://github.com/yanick/environment/commit/4718d7806b48f60b8976d4d76e84de7443b0d873#vim-plugins/project/plugin/project.vim)
such that it would refresh the project listing using my little script. Oh, and
defined a bash alias:

    #syntax: bash
    $ alias pvim
    alias pvim='gvim +'\''Project project.vim'\'''

The result? Not yet a perfect IDE, but it's getting closer... 

<div align="center">
<img src="__ENTRY_DIR__/screenshot.png" />
</div>


[vim]: http://vim.org
