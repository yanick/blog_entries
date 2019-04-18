---
created: 2017-04-02
---

# Perl-Based Neovim Plugins, part 1: Run Dat Service

Quite a few moons ago, I lusted for an easy way to write Vim plugins.
For me easy means "*perl-based*", so I explored [Vim's API][vim-perl-api] for its (optionally)
embedded perl interpreter.
That API is serviceable, but archaic. So that in turn lead to [Vim::X](cpan:Vim-X), which aims
to grease the vim/perl interfacing into the modern age.


Fast-forward a wee bit, and I discover
[neovim](https://neovim.io/).  One of the neat features of this new vi
incarnation is an [RPC interface](https://neovim.io/doc/user/msgpack_rpc.html)
allowing external programs to interact with the editor. That's
a paradigm change from the old Vim way.  Whereas the Vim/Perl API
tightly bind interpreter and editor together (I mean, the interpreter is
compiled as part of the editor. You literally can't get bound tighter than
*that*), now plugins could be written as itsy-bitsy external services
connecting to the editor and doing their things.

That promise of flexibility doesn't come without a few drawbacks. An obvious
one is the complexity of the interactions between the editor and the plugin
services.  Since those interactions now flow through a RPC channel, what were
straight-up function calls now become the intricate asynchronous
dance of requests and responses.

Totally new way of doing things. Twisted jungle of new technologies laid at our feet,
and jagged details at the horizon.  Well, you know me: I had to give it a whirl.

Once the post-whirling dust settled, I had written  [MsgPack::RPC](cpan:MsgPack-RPC) -- to
generically interact with [MsgPack](http://msgpack.org)-based RPC interfaces
-- [Neovim::RPC](cpan:Neovim-RPC) -- to interact with neovim instances -- and
a [couple](http://techblog.babyl.ca/entry/neovimception) of
[blog](http://techblog.babyl.ca/entry/neovim-way-to-go) entries -- to interact
with youses peeps.

Then the project went dormant, as I gamboled away to other wacky ventures.
But I've picked it back recently, and brought quite a few changes to
Neovim::RPC. Enough, I think, to warrant nothing less than a triology of blog
entries.

In this first installment, beside blabbing about the project's origin story
I'll show you how Neovim::RPC is expected to hook to a neovim instance. In the
second part, we'll see how simple plugins are written. And for the third part
we'll take a gander at a bigger, beefier plugin -- namely, we'll use neovim
as a UI for [Taskwarrior](https://taskwarrior.org/).


## Run it: end-user edition

So, let's get to the meat of it. You are an end-user. You just want to
run Neomvim::RPC-based plugins.  What do you need to do?

First, you need to install Neovim::RPC (like, duh).
As I'm writing this, the new code for Neovim::RPC
hasn't been released to CPAN yet. It shouldn't be long before I do it, but if
you want to try it *right now*, it can be sneak-previewed in its [GitHub
repository](https://github.com/yanick/Neovim-RPC).


Next, a few utility functions need to be added to your neovim configuration. I
should (nay, will) wrap all of that in a proper vim configuration file, but
for the time being dropping it straight into your `~/.config/nvim/init.vim`
would do the trick.

```
let g:nvimx_jobid = get(g:, 'nvimx_jobid', 0)

function! Nvimx_start()
    if !g:nvimx_jobid
        let g:nvimx_jobid = jobstart(['nvimx.pl', v:servername ])
        if !g:nvimx_jobid
            echo "could not start nvimx"
        endif
    endif
endfunction

function! Nvimx_stop()
    if g:nvimx_jobid
        call jobstop( g:nvimx_jobid )
        let g:nvimx_jobid=0
    endif
endfunction

function! Nvimx_restart()
    call Nvimx_stop()
    call Nvimx_start()
endfunction

function! Nvimx_termstart()
    " we don't want two instances running...
    call Nvimx_stop()
    new
    execute "terminal nvimx.pl " . v:servername
endfunction

function! Nvimx_notify(...)
    call call( 'rpcnotify',  [g:nvimx_channel]  + a:000 )
endfunction

function! Nvimx_request(...)
    call call( 'rpcrequest',  [g:nvimx_channel]  + a:000 )
endfunction

call Nvimx_start()
```

Once this is done, you can run nvim and, tadah!, a Neovim::RPC minion
should be gently running in the background, thanks to that final `call
Nvimx_start()` in the config
block.  The function `Nvimx_start` starts a job running the script `nvimx.pl`, which is
part of the Neovim::RPC's distribution, and hooks it to the socket of the neovim
instance, as given by `v:servername`.

Of course, since the off-the-shelf Neovim::RPC instance doesn't do much
we can only qualify its presence as being a... quiet one. The only plugin
loaded by default is 'LoadPlugin'. It usually allow us to tell Neovim::RPC
to dynamically load plugins, but for this first run it'll be used as a sign of
life. We can use the vim function `Nvimx_notify` defined in the config
block above to ask Neovim::RPC what's up.

<Asciinema src="/entry/neovim-plugins-part-1/files/enduser.json" />


## Run it: developer edition

As we can see in the previous section, by default Neovim::RPC
doesn't bother the neovim user with log messages. That's usually a good thing, but
when developing new plugins or debugging old ones, a little more noise would
surely be appreciated.

You'll be pleased to know that this is not a problem. We can simply shut down
the too-silent Neovim::RPC instance and replace it by one run directly in a
second terminal, where we'll
be able to see its logs in their glorious details.

<Asciinema src="/entry/neovim-plugins-part-1/files/debug1.json" />

Or... neovim actually boasts a in-editor terminal emulator, so instead of a
second terminal, for bonus ouroboros points, we could have the editor run the terminal emulator running
`nvimx.pl` that is going to connect back to the editor running it.
That's exactly what that `Nvimx_termstart` function does.

<Asciinema src="/entry/neovim-plugins-part-1/files/debug2.json" />

## Coming up next

So far things aren't terribly exciting. But now that we got the
engine humming, in the next
installment we'll be able to get to business. Stay tuned!


[vim-perl-api]: http://vimdoc.sourceforge.net/htmldoc/if_perl.html#perl-using
