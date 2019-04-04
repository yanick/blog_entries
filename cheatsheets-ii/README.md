---
title: Following My Cheating Heart
url: cheatsheet-ii
format: markdown
created: 2015-06-18
tags:
    - perl
    - cheatsheets
---

As you may recall, a few months ago I played with [ways to craft printable, 
vim-edited cheatsheets][previous]. This week I had some time to revisit the endeavour
and refine the process.

First thing I did was to revert to using Markdown rather than the
[vimwiki][vimwiki] markup. Why? Well, for one Markdown is familiar territory,
and there is already Perl modules that grok it and thus can be used
manipulate those cheatsheets. And as a bonus, if I don't go too much outside
of the vanilla Markdown, the raw files already look kinda nice on GitHub.

Talking of GitHub, second thing I did was to create a new repository just for
my cheatsheets. Say hello to [yanick/cheatsheet](gh:yanick/cheatsheets) and
my prototype [cheatsheet for
Fugitive](https://github.com/yanick/cheatsheets/blob/master/vim/fugitive.mkd).

Third thing I did was to tweak and modify the script I was using to convert
the raw Markdown cheatsheets into purtier stuff. It's now
[mkd_cheatsheets.pl](https://github.com/yanick/cheatsheets/blob/master/bin/mkd_cheatsheet.pl),
and that sucker can output the cheatsheet in three different formats.

First format, just [basic html](__ENTRY_DIR__/fugitive.html):

    $ ./bin/mkd_cheatsheets.pl vim/fugitive.mkd

Second format, [pretty pdf](__ENTRY_DIR__/fugitive.pdf), generated via the might of
[prince](http://www.princexml.com/):


    $ ./bin/mkd_cheatsheets.pl --pdf vim/fugitive.mkd

Third format, [bookletified pdf](__ENTRY_DIR__/booklet.pdf), which uses 
[pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) and
[pdfnup](http://linux.die.net/man/1/pdfnup) to reorder pages and gather them
two-per-sheet so that I can fold my cheatsheets in a format pretty close to
the O'Reilly's reference books.

    $ ./bin/mkd_cheatsheets.pl --booklet vim/fugitive.mkd


All in all, it's nothing earth-shattering but I have the feeling I'm slowly 
finding the sweet spot for a system where it's easy to jolt down notes, and 
yet can be easily cleaned up into useful (shareable) booklets.

[previous]: http://techblog.babyl.ca/entry/crafting-cheatsheets
[vimwiki]: https://github.com/vimwiki/vimwiki


