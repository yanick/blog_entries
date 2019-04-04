---
created: 2015-09-16
---

# This Is The NeoVim Way To Go, This Is The Way Of The Futures

Oh boy, that rabbit hole went much deeper than I thought. It was quite the
educational trip too. I now know more about MessagePack
[encoding](blog:neovim-part-1) and [decoding](blog:neovim-part-2) than I ever
wanted to know, not to mention the Message-RPC protocol, which I ended up
[implementing too](cpan:MsgPack-RPC). But I'm finally at a point where I'm
running out of tunnels, and where the white fluffy thing within hands's grasp
might very well be the cotton tail I was after.

Peeps, I give you... [](cpan:Neovim-RPC).

## Rise, Neovim, *Riiiiiiise*

Neovim::RPC is quite different from my earlier [](cpan:Vim-X). Vim::X was
leveraging the fact that vim itself would be compiled with a Perl interpreter.
Neovim takes a different approach: instead of stuffing its guts with every
interpreter under the sun, it allows external programs to interact 
with the editor via MessagePack-RPC. The communication channel can be either 
a socket (local or over tcp), or file handles.

Concretely, that means that the neovim plugin will live as its very own 
persistent Perl client. At its simplest, you create a script `neovim.pl`
that looks like

```perl
#!/usr/bin/env perl 

use strict;
use warnings;

use Neovim::RPC;

my $rpc = Neovim::RPC->new;

$rpc->load_plugin('LoadPlugin');

$rpc->api->vim_set_current_line( line => "hello there" );

$rpc->loop;
```

then in one terminal you launch nvim:

```bash
$ export NVIM_LISTEN_ADDRESS=127.0.0.1:6543
$ nvim
```

and in a second one you run the Perl client:

```bash
$ export NVIM_LISTEN_ADDRESS=127.0.0.1:6543
$ perl neovim.pl
```

If everything went well, a magnificent `hello there` should have appeared in
your nvim buffer.

And yeah, you didn't even had to deal with the socket business. Both nvim and 
the module will use the environment variable `NVIM_LISTEN_ADDRESS` as their
default socket address, if it's defined. "Defaulting hard so you don't have
to" is my motto.

## It comes from within the house

Launching the Perl script ourselves is fine when testing and playing around,
but that's something we'd generally want to be automated. Which is done by
sticking this in your `nvimrc`

```
call rpcstart( "/path/to/neovim.pl" )
```

With it, `neovim.pl` will be spawned as a subprocess of your nvim instance.

## Self-discovered API

By default, the RPC client will query nvim for all the RPC methods it supports
and build its api based on it. To know all the methods available,
you can do

```perl
#!/usr/bin/env perl 

use strict;
use warnings;

use Neovim::RPC;

my $rpc = Neovim::RPC->new->api->print_command;
```

and you should get

```
vim_get_api_info (  ) -> 
vim_get_buffers (  ) -> ArrayOf(Buffer)
vim_get_color_map (  ) -> Dictionary
vim_get_current_buffer (  ) -> Buffer
vim_get_current_line (  ) -> String
vim_get_current_tabpage (  ) -> Tabpage
vim_get_current_window (  ) -> Window
vim_get_option ( String name ) -> Object
vim_get_tabpages (  ) -> ArrayOf(Tabpage)
vim_get_var ( String name ) -> Object
vim_get_vvar ( String name ) -> Object
vim_get_windows (  ) -> ArrayOf(Window)
vim_input ( String keys ) -> Integer
vim_list_runtime_paths (  ) -> ArrayOf(String)
vim_name_to_color ( String name ) -> Integer
vim_out_write ( String str ) -> void
vim_replace_termcodes ( String str, Boolean from_part, Boolean do_lt, Boolean special ) -> String
vim_report_error ( String str ) -> void
vim_set_current_buffer ( Buffer buffer ) -> void
vim_set_current_line ( String line ) -> void
vim_set_current_tabpage ( Tabpage tabpage ) -> void
vim_set_current_window ( Window window ) -> void
vim_set_option ( String name, Object value ) -> void
vim_set_var ( String name, Object value ) -> Object
vim_strwidth ( String str ) -> Integer
vim_subscribe ( String event ) -> void
vim_unsubscribe ( String event ) -> void
window_get_buffer ( Window window ) -> Buffer
window_get_cursor ( Window window ) -> ArrayOf(Integer, 2)
window_get_height ( Window window ) -> Integer
window_get_option ( Window window, String name ) -> Object
window_get_position ( Window window ) -> ArrayOf(Integer, 2)
window_get_tabpage ( Window window ) -> Tabpage
window_get_var ( Window window, String name ) -> Object
window_get_width ( Window window ) -> Integer
window_is_valid ( Window window ) -> Boolean
window_set_cursor ( Window window, ArrayOf(Integer, 2) pos ) -> void
window_set_height ( Window window, Integer height ) -> void
window_set_option ( Window window, String name, Object value ) -> void
window_set_var ( Window window, String name, Object value ) -> Object
window_set_width ( Window window, Integer width ) -> void
```

All those methods will be available off `$rpc->api`.

```perl
    $rpc->api->vim_set_current_line( line => 'Booh-ya' );
```

Oh yes. And during that self-discovery waltz, the client will also
set the variable `nvimx_channel` in nvim to the channel used by the client.
This will come handy later on.

## R'N'R (Requests, Notifications and Responses, natch)

The biggest change that comes from the 
editor and client being separated by a protocolistic chasm. Gone
are the days where you would just ask `get me the content of the current line` and immediately
get it. Now, it's all message-based and asynchronous (although the client itself
is, for now, synchronous). But worry not: I've leveraged the very nice [](cpan:release/Future) module to ease us in that
asynchronous paradigm.

Fortunately, the protocol used is fairly simple to grasp. Two types of
communication can happen between the editor and the client: notifications, and
request/response exchanges.

### Client-initiated request

Request/response exchanges can be initiated by either side. If we do send
a request
from the client side, the command returns a promise that will be fulfilled
whenever we receive the answer from the editor.

```perl

use experimental 'signatures';

$rpc->api->vim_get_current_line
    ->on_done( sub($line) {
        $rpc->api->vim_set_current_line( 
            line => scalar reverse $line
        )->on_done(sub{ say "done!" });
    });
```

Small segue: the previous code could also been written as


```perl

$rpc->api->vim_get_current_line
    ->then( sub($line) {
        $rpc->api->vim_set_current_line( 
            line => scalar reverse $line
        )
    })
    ->on_done(sub{ say "done!" });;
```

if it wasn't for the fact that [chained futures will be forgotten due to some
internal use of weaken
references](https://rt.cpan.org/Public/Bug/Display.html?id=107015). Caveat
Emptor.

### Editor-initiated request

To catch and reply to a editor request, we have to subscribe to the RPC method
that will be used (internally [](cpan:Beam-Emitter) is used for that).

```perl
$rpc->subscribe( 'reverse_me' => sub($msg) {

    $rpc->api->vim_get_current_line
        ->on_done( sub($line) {
            $rpc->api->vim_set_current_line( 
                line => scalar reverse $line
            );
            $msg->done;
        });

});
```

That last `$msg->done` will send the official response to the request,
which is important as the editor will block input until it receives it.

And to send the request from the editor:

```
call rpcrequest(nvimx_channel,"reverse_me",[])
```

Cute detail: RPC calls can also fail, in which case the error message sent
will be displayed in the nvim status line.

```perl
$rpc->subscribe( 'run_me' => sub($msg) {

    $rpc->api->vim_get_current_line
        ->on_done( sub($line) {
           my $result = eval $line;

           return $msg->fail($@) if $@;

            $rpc->api->vim_set_current_line( 
                line => result
            );
            $msg->done;
        });

});
```

### Editor-initiated notifications

Notifications are just like requests, except that they don't expect nor wait
for a response. And so we use the same mechanism as for editor requests for them.


```perl
use experimental qw/ postderef /;

$rpc->subscribe( 'log_me' => sub($msg) {
    print {$log_fh} $msg->args->@*;
});
```

And from nvim:

```
call rpcnotify( nvimx_channel, "log_me", [ "some stuff" ])
```

Funny fact: the same method could easily be invoked as both a request or a
notification.  If you want to go down that route, you can distinguish between
the two uses by looking at what `$msg` is:


```perl
$rpc->subscribe( 'do_something' => sub($msg) {
    my $result = do_it();

    $msg->done($result) if $msg->isa('Neovim::RPC::Message::Request');
});
```

## Plowing toward plugins

Of course, the end-game is to be able to write a bunch of utility functions as
plugins. The basic logic to add them is pretty nice and clean: we need to
subscribe to certain RPC method calls, and map the triggering of those to
whatever we want on the nvim side.

But we aren't savages, and we don't want to just heap those functionalities in
the main `neovimx.pl` script. No, we want to put all those things in neat
little plugins.

Well, go back to the original `neovimx.pl`. See that
`$rpc->add_plugin("LoadPlugin")` call?  Yes, it means that there's already
support for plugins. Moreover, that specific line loads the plugin
*LoadPlugin*, which will allow to load any further plugins from within nvim.
As a bonus, this deliciously meta primordial plugin offers a good example of 
how to define those beasties:

```perl
package Neovim::RPC::Plugin::LoadPlugin;

use 5.20.0;

use strict;
use warnings;

use Moose;
with 'Neovim::RPC::Plugin';

use Try::Tiny;

use experimental 'signatures';

sub BUILD($self,@) {

    $self->subscribe('load_plugin',sub ($msg) { 
        # TODO also deal with it as a request?
        my $plugin = $msg->args->[0];
        try {
            $self->rpc->load_plugin( $plugin );           
        }
        catch {
            $self->api->vim_report_error( str => "failed to load $plugin" );
        }
    });
}

1;
```

Nothing fancy. We are provided the master `$rpc` object via the
`Neovim::RPC::Plugin` role, and at creation time we are expected to register
all the subscriptions we want. And that's it. No, really, it is. Want to have
a plugin that will figure out what's the package name of the current file?

```perl
package Neovim::RPC::Plugin::FileToPackageName;

use 5.20.0;

use strict;
use warnings;

use Moose;
with 'Neovim::RPC::Plugin';

sub file_to_package_name {
    shift
    =~ s#^(.*/)?lib/##r
    =~ s#^/##r
    =~ s#/#::#rg
    =~ s#\.p[ml]$##r;
}

sub BUILD {
    my $self = shift;

    $self->subscribe( 'file_to_package_name', sub {
        my $msg = shift;

        my $y = $self->api
            ->vim_call_function( fname => 'expand', args => [ '%:p' ] )
            ->then( sub {
                $self->api->vim_set_current_line(
                    line => 'package ' . file_to_package_name(shift) . ';' 
                ) 
            });

        $y->on_done(sub{
            $y; # to get around the silly 'weaken' bug
            $msg->done;
        });

    });
}

1;
```

And, nvim-side:

```
call rpcnotify( 0, "load_plugin", "FileToPackageName" )
call rpcrequest( nvimx_channel, "file_to_package_name" )
```

And **boom** plugin plugged.


## Getting loopy

Last bit of this first tour of the property. The neovim script will typically
end with a call to `loop()`, which will listen to the input channel and fire
message events as required. But for cases where forever is too much, 
the method can be given arguments to tell it when enough is enough. 

At the most simple, we can tell it to process `n` incoming messages.

```perl
$rpc->loop(5);
```

We can also give it a code ref, which will be evaluated on each new incoming
message and interrupt the loop as soon as it becomes true.

```perl
$rpc->loop(sub{ -f '/tmp/emergency_break' });
```

And, finally, it can take a Future promise, and will bail out once that
promise
is fulfilled. Which allows for nice things like


```perl
my $future = $rpc->api->vim_get_current_line;

# will read until we get an answer to our
# request
$rpc->loop($future);
```

