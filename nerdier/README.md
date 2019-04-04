---
created: 2018-05-24
---

# Vim IDE: nerdier than NERDtree

Quite often, when peeps talk of using Vim as an IDE, [Nerdtree][]
is pointed out as the way to navigate files. Mind you, with perfectly 
good reasons; that plugin is awesome and I relish using it.
But I often found myself wishing
the organization of my files to go beyond alphabetical sorting.
I'd want to group files thematically, put the important ones up top and
the boring ones way down, totally ignore the usual suspects.

As it is, there is another vim plugin, [project.vim][] that does most of
that. Most, but not all. That's unacceptable, and needs to be
rectified.

## The setup

One of my goals here was not to reinvent the wheel, but rather add hubcaps to
an already existing one. Which means that the final setup is a tad patchworky.

First it has to be said that I'm using [nvim][] rather than the classical vim.
Which is important because I'm running my [Neovim::RPC][] as well. Which is
*also* important because the hacking I've done atop `project.vim` is in the
form of a Neovim::RPC plugin, which -- if you already have Neovim::RPC up and
running -- you can get it via:

```
$ git clone https://github.com/yanick/Neovim-Rpc
$ cd Neovim-Rpc
$ git checkout pvim
$ mkdir -p ~/.config/nvim/perl5lib/Neovim/RPC/Plugin
$ cp -r lib/Neovim/RPC/Plugin/Pvim* ~/.config/nvim/perl5lib/Neovim/RPC/Plugin
```

Then we need to add some vim configuration.

```
" I'm using 'plugged' for my vim plugins

""" vim-plug {{{
    call plug#begin('~/.config/nvim/plugged')

    Plug 'yanick/vim-project'

    call plug#end()
""" }}}

""" projects {{{

    map <F10> :Project .git/vim.project<CR>

    au BufNewFile,BufRead vim.project set filetype=project

    au FileType project set noswapfile
    au FileType project nmap <buffer><F5> :call PvimRefresh()<CR>
    au FileType project vmap <buffer><F4> :call PvimSection()<CR>

    function! PvimRefresh() 
        call Nvimx_request( 'load_plugin', 'Pvim' )
        call Nvimx_request('pvim_update')
    endfunction

    function! PvimSection() range 
        call Nvimx_request( 'load_plugin', 'Pvim' )
        call Nvimx_request( 'pvim_section', a:firstline, a:lastline )
    endfunction

""" }}}
```

Oh yeah, and because I'm a lazy bugger, I also defined 
[neosnippets][] to go with `project` files:

```
snippet     section
options     head
    ${1:name}     Files=${2:$1} {
        ${0}
    }

snippet project
alias   pro
options head
    ${1:project}=`getcwd()` CD=. 
    
```

And just like that, we're good to go.

## The way it works

Assuming that `vim` is open in the root directory of your project,
hitting `F10` triggers the project sidebar.  The behavior and display
of that sidebar is driven by the `project.vim` plugin, except for what will be
said here. The project file, by the way, is assumed to be `.git/vim.project`. 


`F5` refreshes the listing of files. All files already
listed will stay in the sections where they are. The global listing order is ungrouped files, sections, and ignore patterns.
New files are plonked in the most specific
section it belongs to. Files that disappeared will be prepended with a `#`.
Files and directories can be ignored via a `#! <regex>` line -- where the
regex is anchored at the beginning of the file name.

Selecting lines in visual mode and hitting `F4` will create a section, and
will set the directory of that section to be the deepest common subdirectory
to all files selected.

And that's it. Wanna see it in action?

<asciinema-player src="/entry/nerdier/files/nerdier.json" />


[Neovim::RPC]: cpan:Neovim::RPC
[Nerdtree]:   https://github.com/scrooloose/nerdtree
[neosnippets]:  https://github.com/Shougo/neosnippet.vim
[nvim]: https://neovim.io/
[project.vim]: https://github.com/yanick/vim-project
