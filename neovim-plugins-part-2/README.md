---
created: 2017-04-11
---

# Perl-Based Neovim Plugins, part 2: from File Path to Package Name

Welcome back! Quick recap: we are in the midst of an epic blog series about
[Neovim::RPC](cpan:Neovim-RPC) and how it can be used to 
write [neovim](https://neovim.io) plugins. [Last
time](http://techblog.babyl.ca/entry/neovim-plugins-part-1) we covered how to install the beast, and this time around we'll 
implement a first plugin.

## The endgame

For this first plugin we'll go with some very, very simple stuff: it will
drive a macro generating a module's package name based on its file path.
Basically, it'll figure out that the module at
`/home/yanick/work/Neovim-RPC/lib/Neovim/RPC/Plugin/FileToPackageName.pm` should 
be named `Neovim::RPC::Plugin::FileToPackageName`.
Nothing fancy, in fact could probably be done via vim-powered
regular expressions, but that simplicity will give us a great starting point.

## Hell is interoperability

The nice thing about blog entries is how the author usually filters out the many
liters of "why aren't you  working the way I want you to work, you sanity-eroding
piece of blasted malappropriation?", and distill it into a few precious droplets
of "isn't this easy?". 

Well, this isn't your usual author. I'll get to the "isn't this easy?" part in the next section. But I want
to share out a few gnashing of teeth first. For education purposes.

I use [UltiSnips](https://github.com/SirVer/ultisnips) 
for my code snippets, and I love it dearly. It has a way
to call vim code directly from a snippet, so I thought that hooking the plugin
call into a snippet would be child's play. Something like:


```vim
snippet package "package definition" b
package `!v FileToPackage()`
endsnippet
```

AH! I can such a fool.

As it turns out, although a msgpack-rpc response can carry a payload, neovim
doesn't seem to pass it back in any way (and, please, if I overlooked
something and you know better, let me know in the comments). Well, fine, I'll
have the snippet put in a `__PACKAGE__` placeholder and 
have the plugin alter it behind the scene. But then that `!v` snippet
inserts its output, which is always a `0`, into the mix. One messy way to get around
all that stuff is to do:

```vim
" in init.vim

function FileToPackage()
    call Nvimx_notify( 'load_plugin', 'FileToPackageName' )
    call Nvimx_request('file_to_package_name')
endfunction

command FileToPackage :call FileToPackage()

" ... and then in the ultisnips snippet definitions

snippet package "package definition" b
package __PACKAGE__; `!v FileToPackage()?"":""`
endsnippet

```

I could also just have done something like

```
imap @@package package __PACKAGE__;<ESC>:call FileToPackage()<CR>o
```

but I was kinda set on showing UltiSnips who's boss. For the moment,
it'll have to do, but there is definitively
room for improvement.

## Plugin on the vim side

In the last section, we already saw the vim-side function that will interact with
the plugin. 

##hackthrough

### ./filetopackage.vim @2,3

We use `Nvimx_notify` and `Nvimx_request`, two helper functions we 
saw in the [previous blog entry](http://techblog.babyl.ca/entry/neovim-plugins-part-1). They are just thin wrappers around
`rpcnotify` and `rpcrequest` using the channel on which `neovimx` is listening.

### ./filetopackage.vim @2

On-demand plugin loading! Since it's in the function, we only load the plugin when it's first used 
(subsequent calls will amount to be no-ops, so it's fine)

### ./filetopackage.vim @3

We use a `rpcrequest`, as opposed to a `rpcnotify` to pause the ui while we replace that line.

##/hackthrough

## Plugin on the Perl side

Here comes the *plat de r&eacute;sistance*. First, let's implement it in a straight-forward, naive way.

##hackthrough

### ./Pluginv2.perl

We start with the basic declaration. `use Neovim::RPC::Plugin` automatically sets the current class to extends `Neovim::RPC::Plugin`. 

### ./Pluginv3.perl

Then we implement the function that actually do the work of converting the path
to a package name. Woohoo, regex fun!

### ./Pluginv4.perl @2-15

And then we hook up the plugin to listen to `file_to_package_name` requests coming
from neovim.

### ./Pluginv5.perl @5-6,18-23

When we do get a request, we query back neovim to know which file path is associated with the current buffer...

### ./Pluginv4.perl @7-13

...then we get the current line, fill in the `__PACKAGE__` placeholder
and send it back...

### ./Pluginv4.perl @14

...and finally reply to the original request, so that the UI gets unblocked.

(we use `finally` instead of `then` so that it'll get unblocked, even if
something throws an exception in the previous promises)

##/hackthrough

Doesn't look too bad, right? But wait! There is a few optimizations I've 
slipped in `Neovim::RPC::Plugin` to make it even easier to work with.

##hackthrough

### ./Pluginv4.perl

Let's begin where we left off.

### ./Pluginv7.perl @1

Instead of the awkward `BUILD` construct, there is a DSL keyword, `subscribe`,
that registers the subscription against the class.

### ./Pluginv8.perl @1

Since an `rpcrequest` always requires a response, there is another DSL keyword,
`rpcrequest()`, that wraps subsequent coderefs so that the request's response is
automatically sent when they are all done.

### ./Pluginv9.perl @2-14

Writing those chains of `then` is not exactly a hardship, but it's a little noisy.
`subscribe` knows  to turn a list of coderefs into such a promise chain, so we
can unclutter the code.  

Not that it improves much on things here, mind you.

### ./Pluginv10.perl @3-6

By the by, notice how fetching the file path and current line
aren't related? We can break the linear chain and use `collect_props`.

Now, *that* looks better.

##/hackthrough

And this is it. In its final form, the plugin looks like


```perl
package Neovim::RPC::Plugin::FileToPackageName;

use 5.20.0;
use warnings;

use Neovim::RPC::Plugin;

use experimental 'signatures';

sub file_to_package_name {
    shift
    =~ s#^(.*/)?lib/##r
    =~ s#^/##r
    =~ s#/#::#rg
    =~ s#\.p[ml]$##r;
}

sub shall_get_filename ($self) {
    $self->api->vim_call_function(
        fname => 'expand', args => [ '%:p' ] 
    );
}

subscribe file_to_package_name => rpcrequest 
    sub($self,@) {
        collect_props(
            filename => $self->shall_get_filename,
            line     => $self->api->vim_get_current_line,
        )
    },
    sub ($self,$props) {
        $self->api->vim_set_current_line(
            $props->{line} =~ s/__PACKAGE__/
                file_to_package_name($props->{filename})
            /er
        )
    };

1;
```

And that's it...

## Well...

...almost. That `collect_props` function? It's not currently
part of the Promises module, but there is a [pull request](https://github.com/stevan/promises-perl/pull/52)
for it. In the meantime, this is what it looks like:

```perl
sub collect_props {
    use Promises qw/ deferred /;
    my %promises = @_;

    my $all_done  = deferred();

    my $results   = {};
    my $remaining = scalar keys %promises;

    my $are_we_there_yet = sub {
        return if --$remaining;

        return if $all_done->is_rejected;

        $all_done->resolve($results);
    };

    while( my( $key, $promise ) = each %promises ) {
        unless( ref $promise eq 'Promises::Promise' 
             or ref $promise eq 'Promises::Deferred' ) {
            my $p = deferred();
            $p->resolve($promise);
            $promise = $p;
        }

        $promise->then(sub{ $results->{$key} = shift })
            ->then( $are_we_there_yet, sub { $all_done->reject(@_) } );
    }

    return $all_done->promise;
}
```

## To be continued

Next time, we'll ratchet things up and attack slightly more meaty plugins. ...in fact, I'm beginning to think that this advertised trilogy might grow a few more installments...


