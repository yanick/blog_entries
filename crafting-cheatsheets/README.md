---
title: Crafting Cheatsheets
url: crafting-cheatsheets
format: markdown
created: 25 Jan 2015
tags:
    - cheatsheets
    - vim
---

I am balefully under-leveraging the tools at my disposal. 

Not that I think I am alone in my plight, mind you. Technology barrels down
its virtual highway so fast we barely have the time to register any newcomer
before it screams past us and doppler itself off our field of vision. That, or
it's a leviathan of such proportion that only grasping its general shape  
rightfully requires diligent years of study.

Documentation is, of course, the main instrument that we have to break those
mind-mustangs. One of my personal traditions is to acquire one core dead-tree 
reference for any major technology I dabble in. But while that helps with the
big picture, it's less effective for the day-to-day use of new tools --
minor tools, like plugins and addons that are too ephemeral or infinitesimal 
to appear in pulp-enshrouded tomes. For those slender software slivers,
it usually pay off to bolt down a few notes and form a cheatsheet that one can
refer to quickly and easily.

Sounds simple, right? But, in my case, things get complicated by two things:
(a) my penmanship is encryption-grade terrible and (b) I'm not a man who leave
good enough alone. So I went on a quest to set up, if not the most reasonable, 
at least the snazziest cheatsheet system possible.

First challenge: cheatsheets must be easy to jolt down. For that, no fancy 
markup, just something wikiish or markdownese. Bonus points if it
lives within the editor I already use most of the time. 

Happily enough, such a
beast exist: [vimwiki](https://github.com/vimwiki/vimwiki), a vim-based 
personal wiki. Its native syntax is tame enough (and it supports Markdown
too), and it has real nice support for tables. For those not convinced, here's
exhibit A: my [cheatsheet for
Impaired](https://raw.githubusercontent.com/yanick/environment/master/cheatsheets/src/vim/unimpaired.wiki).

But I said I wanted to have those cheatsheets near at hand, and for once I was
not metaphorical -- I want to print those cheatsheets. As luck has it, vimwiki
does generate HTML output of its pages. By default the pages are faily bland,
but it's nothing that a little [styling](https://github.com/yanick/environment/blob/master/cheatsheets/html/style.css), 
and a little [mangling](https://github.com/yanick/environment/blob/master/cheatsheets/html/tweaks.js)
can't improve.

To get from the HTML document to a printer-ready PDF, we have several options.
We could go via any browser, or use PhantomJS, but I elected to go with 
[Prince](http://www.princexml.com/); it's free for personal use, and is very,
very good at what it does.

And just like that we have our PDFs. Are we done? Not quite. Just to be difficult, I 
also want to
print those cheatsheets as booklets. I could write a small script to juggle
and rearrange
the pages of the PDF documents to acheive that, but it happens that 
there's [a tool that already does that](http://pdfbooklet.sourceforge.net/).

One job sent to the  printer later, and a first of many cheatsheets 
adorn my desk.

![impaired cheatsheet](__ENTRY_DIR__/cheatsheet.jpg)
