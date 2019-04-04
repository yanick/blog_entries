---
url: new-and-improved
format: markdown
created: 24 Oct 2011
tags:
    - Perl
    - New and Improved
    - Dancer
    - Dancer::Plugin::Cache::CHI
    - DBD::Oracle
---

# New and Improved: Dancer::Plugin::Cache::CHI and DBD::Oracle

<div style="float: right; padding: 5px;">
<img src="__ENTRY_DIR__/val_approuve.png" alt="New and Improved!" width="300"/>
</div>

I think it was Gabor who was mentioning that we should promote a little bit
more the distributions we upload on CPAN. He's right. A falling tree might or might
not make a sound if no-one is present, but it sure doesn't hurt to yell
"Timber!". 

... 

Hum. Okay, that was a remarkably bad metaphor, but you hopefully know what I mean. Anyway, all
that to say welcome to *New & Improved* blog entries, where I quickly showcase
any new distribution o' mine that have new stuff worth mentioning. 

To start the show, two distributions for the price of one:
[Dancer::Plugin::Cache::CHI](cpan) and [DBD::Oracle](cpan).


## Dancer::Plugin::Cache::CHI

[Dancer::Plugin::Cache::CHI](cpan) v1.2.0 has hit CPAN a few days ago. In
that release, four new goodies have appeared.

### `before_create_cache` hook

We now have a hook that gets triggered just before the cache object is 
created.  Can be useful for programatically massaging the cache's
configuration.  For example, if the application is run on different machines
with a shared cache, one way to have the cache's namespace set to the host
machine would be:

    #syntax: perl
    use Sys::Hostname;

    hook before_create_cache => sub {
        config->{plugins}{'Cache::CHI'}{namespace} = hostname;
    };

### The whole response is cached, not only the content

In the previous versions, '`cache_page`' would cache the content
of the response only. Now, we cache the response's headers and 
status as well.  Plus, under the hood we don't `halt()` anymore, 
which is hopefully D::P::C::C play more nicely with other plugins. 

### '`honor_no_cache`' configuration option

[The standard](http://www.ietf.org/rfc/rfc2616.txt) says that
a request can ask for a fresh, never-cached, response by 
passing the option '`no-cache`' via the '`Cache-Control`'
or '`Pragma`' http header. If you want to abide to the will of the
user, we now have a configuration item for that:

    #syntax: bash
    plugins:
        Cache-CHI:
            driver: Memory
            global: 1
            expires_in: 1 min
            honor_no_cache: 1

With *honor_no_cache* set to true, pages cached with `cache_page()` will
automagically obey and flush the cache if the agent asks so.

### Customizable cache keys

The cache keys now can be customized via `cache_page_key_generator()`.
Want to include the name of the host in the cache key (again, if dealing with
a multi-hosted app)? Easy:

    #syntax: perl
    cache_page_key_generator sub {
        return join ":", request()->host, request()->path_info;
    };

Also, the generated key can also be accessed via `cache_page_key()`:

    #syntax: perl
    get '/page/*' => sub {
        push @cached_pages, cache_page_key();

        return cache_page generate_page( splat );
    };


## DBD::Oracle

Did you know that the `Makefile.PL` of [DBD::Oracle](cpan) has a bunch of
options? Me neither.  But as of version 1.32, you can see'em all by doing:

    #syntax: bash
    $ perl Makefile.PL --help                                                                                         
    Options:
        -b  Try to use Oracle's own 'build' rule. Defaults to true.

        -r  With '-b', use this names build rule (eg -r=build64).

        -m  Path to 'oracle.mk'

        -h  Path to oracle header files.

        -p  Alter preference for oracle.mk.

        -n  Oracle .mk macro name to use for library list to link with.

        -c  Don't encourage use of shared library.

        -l  Try direct-link to libclntsh.

        -g  Enable debugging (-g for compiler and linker).

        -s  Find a symbol in oracle libs, Don't build a Makefile.

        -S  Find a symbol in oracle & system libs, Don't build a Makefile.

        -v  Be more verbose.

        -d  Much more verbose for debugging.

        -f  Include text of oracle's .mk file within generated Makefile.

        -F  Force - ignore errors.

        -W  Just write a basic default Makefile (won't build).

        -w  Enable many gcc compiler warnings.

        -V  Force assumption of specified Oracle version If == 8 then we don't
            use the new OCI_INIT code and we force our emulation of
            OCILobWriteAppend.

