---
created: 2018-10-02
tags:
    - neovim 
    - javascript 
    - perl 
---

# Neovim Remote Plugins: NodeJS Strikes Back 

Recap: I've been on a life-long quest to custom Vim to the point where
it'd become impossible to know where the editor stops and the man begins.
I experimented with Vim's embedded Perl interperter and created 
a [plugin system][cpan:Vim-X] for it (as documented [here][VimX-blog]. 
Then I discovered [Neovim](https://neovim.io). Highly
compatible, but with less cruft and a few extra goodies over classic Vim. 
One of those goodies was an asynchronous RPC interface for external plugins.
That's not the kind of shininess that can be resisted, so I migrated. Writing
another plugin system for Perl-based plugins along the way, because of 
course I had to.

But this week, I found out that while I had to, I might not have to anymore.

## Remote Plugins

When I wrote [Neovim::RPC][], I only knew of the core [msgpack RPC support][msgpack rpc]
of Neovim. Writing plugins was the (relatively) easy part. The devilish 
details were in the trimmings: 
the VimL code needed to start the child Perl process, the on-demand loading
of plugins the Perl 
process itself had to have so that 
it'd not have to load the world on startup all the time,
etc.

As it turns out, Neovim has this concept of [remote plugins][], 
which provides a standard way of dealing with that heavy lifting.

### Remote Host Powered Plugins 

How does it work? Well, let's assume that your favorite language is 
supported (right now, off the shelf the choices are JavaScript, Python, Python3,
and Ruby). 

Say it's JavaScript.  In that case 
you'd drop a JavaScript script (or project directory) 
in `~/.config/nvim/rplugin/node`.
Then from within neovim you'd run the command `:UpdateRemotePlugins`,
which visits all plugins and generates the list of commands, functions,
and autocommands they provides, which is then saved in
`~/.local/share/nvim/rplugin.vim`. 


That file will look something like:

<SnippetFile src="file-4.vim" />

The cool part is that thanks to that file, Neovim is aware of the available functions and commands, 
but will only evaluate the plugins' code when they are invoked. 
Better still: the remote host itself will only spin to life when one of its plugins is
used.

That pay-as-you-go approach means much faster startup time, and let me
have as many plugins as I want without the fear of savaging my memory budget
each time I open a new log file.

## A Perl Remote Host?

As you might have noticed, Perl is missing from the list of supported remote
host languages. This is something that could be rectified with a little bit of
elbow grease. `Neovim::RPC` already does most of what the 
other remote hosts are doing, the trick would be to tweak it to conform to the 
[standard remote host behavior][remote host], taking of the 
already-implemented host as an [example][remote host node]. 

And I might do just that one of these days. But right now, I thought I'd try 
the already-supported JavaScript remote host, for giggles and a few good
reasons.

1.  It's already there. Although I love building my own monuments to
Hubris, sometimes a freebie does feel good.

2. JavaScript was still using the Promise paradigm when I had my original
stab at `Neovim::RPC`. Granted, the JavaScript Promises are a tad more 
natural than the Perl [Promises](cpan:Promises), but the difference
is not overwhelming. But since then, JavaScript came up with `async / await`, 
and **that** mechanism does makes writing asynchronous code much more legible.

3. The way `Neovim::RPC` works right now, it's always invoked when neovim
starts, and it weights close to 50M. The JavaScript remote host clocks less
than half of that, and as mentioned above, does not even appears until
a plugin is explicitly required.  


All that to say that, for once, I was curious to try what was already on offer
before rushing in and reimplenting it myself. What do you know, I might
actually getting wiser in my old age...

## Comparison study #1

For a first comparison, I picked a very simple plugin. Its whole purpose
in life is to replace the token `__PACKAGE__` in the current
line into the Perl module representation of the filename -- the end-goal
being having a snippet/macro take automatically inserting `package Foo::Bar;`
in the Perl file `./lib/Foo/Bar.pm`.

With `Neovim::RPC`, the plugin looks like 

<SnippetFile src="file-3.perl" />

And it needs the following glue in the neovim config:

<SnippetFile src="file-2.vim" />

It's... not bad. We request the filename and the current line's content
from neovim (in the form of promises, because asynchronicity), munge the line 
with the resolved package name, and then push it back to the editor.
Admittedly not cristal-clear at first read, but nothing that
will straight-up make you reach for the bottle.

What does does the JavaScript version looks like? Like this:

<SnippetFile src="file-1.javascript" />

The regular expression leger-de-main isn't as crisp, but `setPackageName` is much more straightforward than 
`file_to_package_name`, mostly thanks to the `await`s replacing the 
need for chained promise-yielding functions. Plus the need for the VimL glue
is removed. Which is very nice because... Perl? *Sure!* JavaScript?
*Why not.* VimL? *Do I really have to?*


## Comparison study #2

I have to say, the JavaScript version only looks better as the complexity
of the asynchronous conversation between the plugin and neovim 
increases. For this example, I'm revisiting the command `TW_show` from
my [neovim-based Taskwarrior UI](http://techblog.babyl.ca/entry/tasknvimrrior). In Perl, it looks like:

<SnippetFile src="v2.perl" />

The JavaScript version (with the declaration order reversed to ease the comparison with 
the Perl version):

<SnippetFile src="v2.javascript" />

I have to admit: I dig it. I dig it a lot.

## Switching Allegiance

Although I'm still awfully proud of the `Neovim::RPC` monster I've cobbled together,
right now it seems that wisdom lies in joining the side favored by the winds of victory.
The [node client](https://github.com/neovim/node-client) is officially supported 
by the Neovim crew and works pretty much out of the box. This means that remote 
plugins are fairly easy to share bundled as regular plugins -- a huge difference 
with the `Neovim::RPC`-based plugins that, while theoretically distributable to the masses,
involve to jump through a number of hoops that practically shrinks the potential userbase 
to a fairly small number (in all likelihood: 1). Plus, that JavaScript client 
features good debugging facilities. And asynchronicity just feels more at home in JS-land.

So... what I guess I'm saying is: looks like I have a few plugins to convert. Should keep me 
busy for a few days.




[msgpack rpc]: https://github.com/neovim/neovim/blob/master/runtime/doc/msgpack_rpc.txt
[remote plugins]: https://neovim.io/doc/user/remote_plugin.html 
[remote host]: https://github.com/neovim/neovim/blob/master/runtime/autoload/remote/host.vim
[remote host node]: https://github.com/neovim/neovim/blob/master/runtime/autoload/provider/node.vim
[Vim::X]: https://metacpan.org/pod/Vim::X
[VimX-blog]: http://techblog.babyl.ca/entry/vim-x
[Neovim::RPC]: https://metacpan.org/release/Neovim-RPC
[neovim-blog]: http://techblog.babyl.ca/entry/neovim-plugins-part-2
