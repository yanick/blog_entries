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

```vim
" node plugins
call remote#host#RegisterPlugin('node', '/home/yanick/.config/nvim/rplugin/node/packageName.js', [
    \ {'sync': v:null, 'name': 'SetPackageName', 'type': 'command', 'opts': {}},
    \ ])
call remote#host#RegisterPlugin('node', '/home/yanick/.config/nvim/rplugin/node/taskwarrior', [
    \ {'sync': v:null, 'name': 'TaskShow', 'type': 'function', 'opts': {}},
    \ ])


" python3 plugins
call remote#host#RegisterPlugin('python3', '/home/yanick/.config/nvim/plugged/deoplete.nvim/rplugin/python3/deoplete', [
    \ {'sync': v:false, 'name': '_deoplete_init', 'opts': {}, 'type': 'function'},
    \ ])
```

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

```perl

package Neovim::RPC::Plugin::FileToPackageName;

use 5.20.0;

use strict;
use warnings;

use Neovim::RPC::Plugin;

use Promises qw/ collect /;

use experimental 'signatures';

sub file_to_package_name {
    shift
        =~ s#^(.*/)?lib/##r
        =~ s#^/##r
        =~ s#/#::#rg
        =~ s#\.p[ml]$##r;
}

sub shall_get_filename ($self) {
    $self->api->vim_call_function( fname => 'expand', args => [ '%:p' ] );
}

subscribe file_to_package_name => rpcrequest 
    sub($self,@) {
        collect(
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

```

And it needs the following glue in the neovim config:

```vim
function! FileToPackage()
    call Nvimx_request( 'load_plugin', 'FileToPackageName' )
    call Nvimx_request('file_to_package_name')
endfunction
```

It's... not bad. We request the filename and the current line's content
from neovim (in the form of promises, because asynchronicity), munge the line 
with the resolved package name, and then push it back to the editor.
Admittedly not cristal-clear at first read, but nothing that
will straight-up make you reach for the bottle.

What does does the JavaScript version looks like? Like this:

```javascript
function expandPackage( line, filename ) {
    let packageName = filename 
        .replace( /^(.*\/)?lib\//, '' )
        .replace( /^\//, '' )
        .replace( /\//g, '::' )
        .replace( /\.p[ml]$/, '' );

    return line.replace( '__PACKAGE__', packageName );
}

const setPackageName = plugin => async () => {
    let [ filename, line ] = await Promise.all([
        plugin.nvim.callFunction( 'expand', [ '%:p' ] ),
        plugin.nvim.getLine(),
    ]);

    await plugin.nvim.setLine( expandPackage(line,filename) );
};

module.exports = plugin => {
    plugin.registerCommand( 'SetPackageName', setPackageName(plugin) );
};
```


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

```perl

subscribe tw_show => rpcrequest 
    sub( $self, $event ) {
        my $buffer_id;

        $self->rpc->api->vim_get_current_buffer
        ->then(sub{ $buffer_id = ord $_[0]->data })
        ->then(sub{
            my @tasks = $self->task->export( '+READY', $event->all_params );

            my @things = 
                map { $self->task_line($_) } 
                sort { $b->{urgency}  - $a->{urgency} } 
                @tasks;

            s/\n/ /g for @things;

            return @things;
        })
        ->then( sub{
            $self->rpc->api->nvim_buf_set_lines( $buffer_id, 0, 1E6, 0, [ @_ ] );
        })
},
        sub { $_[0]->rpc->api->vim_input( '1G' ); },
        sub { $_[0]->rpc->api->vim_command( ':TableModeRealign' ); };

sub task_line($self,$task) {
    $task->{urgency} = sprintf "%03d", $task->{urgency};
    $task->{tags} &&= join ' ', $task->{tags}->@*;

    no warnings 'uninitialized';
    if ( length $task->{project} > 15 ) {
        $task->{project} = ( substr $task->{description}, 0, 12 ) . '...';
    }

    $task->{$_} = relative_time($task->{$_}) for qw/ due /; 
    $task->{$_} = relative_time($task->{$_},-1) for qw/ modified /; 

    no warnings;
    return join '|', undef, 
            $task->@{qw/ urgency priority due description project tags modified uuid /},
            undef;
}

sub relative_time($date,$mult=1) {
    state $now = DateTime->now;

    return unless $date;

    # fine, I'll calculate it like a savage

    $date = DateTime::Format::ISO8601->parse_datetime($date)->epoch;

    my $delta = int( $mult * ( $date - time ) / 60 / 60 / 24 );

    return int($delta/365) . 'y' if abs($delta) > 365;
    return int($delta/30) . 'm' if abs($delta) > 30;
    return int($delta/7) . 'w' if abs($delta) > 7;
    return $delta . 'd';
}

```

The JavaScript version (with the declaration order reversed to ease the comparison with 
the Perl version):

```javascript
module.exports = plugin => {
    const _ = require('lodash');

    plugin.tw = _.once( () => { 
        const Taskwarrior = require( './taskwarrior').default;
        return new Taskwarrior();
    });

    plugin.registerFunction( 'TaskShow', taskShow(plugin) );
};

const taskShow = plugin => async ( filter = [] ) => {

    console.log( "filter: ", filter );

    const fp = require('lodash/fp');

    let tasks = await plugin.tw().export( filter ) 
                |> fp.sortBy( 'data.urgency' )
                |> fp.reverse 
                |> fp.map( taskLine );

    await replaceCurrentBuffer(plugin)(tasks);

    await Promise.all([
        plugin.nvim.input('1G'),
        plugin.nvim.command(':TableModeRealign'),
    ]);
};

const replaceCurrentBuffer = plugin => async ( lines ) => {
    const buffer = await plugin.nvim.buffer;

    await buffer.setLines(lines, {
        start: 0, end: -1, strictIndexing: true,
    });
};

function taskLine( {data} ) {
    const _ = require('lodash');

    data.urgency = parseInt(data.urgency);

    if( data.tags ) data.tags = data.tags.join(' ');

    if ( data.project && data.project.length > 15 ) {
        data.project = _.truncate( data.project, 15 );
    }

    const moment = require('moment');

    [ 'due', 'modified' ].filter( f => data[f] ).forEach( f => {
        data[f] = moment(data[f]).toNow();
    });

    return '|' + [
        'urgency', 'priority', 'due', 'description', 'project',
        'tags', 'modified', 'uuid'
    ].map( k => data[k] || ' ' ).join( '|' ).replace( /\n/g, ' ' );

}

```

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
