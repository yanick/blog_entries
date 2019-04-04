---
created: 2017-11-26
tags: 
    - neovim 
    - taskwarrior
---

# tasknvimwrrior - nvim as a UI for taskwarrior

A super-quick one for today.

So, for input and quick interaction with Taskwarrior, I use the command line.
Like, duh, it's kind of the whole point, isn't?

But sometimes, I want to act on whole lists. And for that I want something
just a tad more user interfacey than the command line.

So I reached out for [Neovim-RPC](cpan:Neovim-RPC) and wrote a very quick and 
dirty UI. Basically, it does two main things: it lists a set of tasks in
a table format (and then I leverage the
[TableMode](gh:dhruvasagar/vim-table-mode) vim plugin to take care of making
it pretty), and it ferries back and forth edit commands like "add this tag",
"give me the list of all the high priority tasks", etc.

Oh yeah, and it's alpha software at its best. How alpha? I'm going to deploy
the modules minutes before I publish that blog entry. That's how alpha. Caveat
emptor, peeps, caveat as much as you can possibly emptor.

## How to install

Simple! Well, somewhat simple. Maybe...

First, you install [Neovim-RPC](cpan:Neovim-RPC) and configure
`nvim` to use it. (I dearly hope the instructions in that module are
up-to-date. If not, they will (eventually) be)

Then you install
[Neovim-RPC-Plugin-Taskwarrior](cpan:Neovim-RPC-Plugin-Taskwarrior) as a
module.

    $ cpanm Neovim-RPC-Plugin-Task

Then you install both the vim glue for the plugin and the TableMode vim plugin
on the neovim side.  If you are using C<Plugged> as your plugin manager, you
can do it by dropping the following in yout `init.vim`:

    Plug 'yanick/Neovim-RPC-Plugin-Taskwarrior'
    Plug 'dhruvasagar/vim-table-mode', {
        \ 'on': [ 'TableModeEnable' ]
    \ }


And then, in theory, you're set. To invoke the UI right off the bat, you can
do

    $ nvim -c 'call Task()`

and magic will happen.

## Show me!

This is something that is better shown than explained. So here's an asciivid
where I

* open the UI. It'll show all pending tasks by default. The columns displayed
    are the emergency level, the priority, the due date (if any), the description,
    tags, the project, the last modified date, and, finally, the task's sha1.
* use the command `<leader>lq` (for <b>l</b>ist <b>q</b>uery) and select to only see the
    tasks of the `oculi` project.
* get more info for one of the tasks via `<leader>i` (for <b>i</b>nfo).
* set all priorities of the tasks to be `low` via a visual selection and
    the command `<leader>pl` (for <b>p</b>riority <b>r</b>ow).
* reorder the table per-emergency via `<leader>tS` (for <b>t</b>able
    <b>s</b>ort).
* finally mark one task as done via `<leader>d`.

<asciinema-player src="/entry/tasknvimrrior/files/demo.json" />
