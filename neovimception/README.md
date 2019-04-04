---
created: 2015-09-19
---

# Neovimception

Nothing huge to announce. Just that there is a new
version of [](cpan:Neovim-RPC) on its way to CPAN, and
it allows to export the RPC API as wrapped functions, 
which make it easier to use them as a DSL:

```perl
use Neovim::RPC;

Neovim::RPC->new->api->export_dsl(1);

vim_set_current_line( "hello there" );
```

That is quite useful when paired with [](cpan:release/Reply),
which has function tab-completion.

Oh, and did I ever told you that neovim comes with support for
embedded terminals? Where, say, we could be running `reply`...

<iframe src="./neovim.showterm" class="showterm">
</iframe>

So, yeah, I can now control neovim from Perl running inside neovim.

Oh, and did I mention that reply can invoke an editor to edit its code too?
Aaah, yes. From the horrified glint in your eyes, I see you understand what it
means.  

You may scream, if you think it'll help.


