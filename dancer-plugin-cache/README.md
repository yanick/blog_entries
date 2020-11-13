---
url: writing-a-dancer-plugin
created: 2011-03-27
tags:
    - Perl
    - Dancer
    - Dancer::Plugin::Cache
    - Dancer::Plugin::Memcached
---

# Writing a Dancer Plugin

Last week I was looking at what [Dancer](cpan) had to
offer in term of cache plugins. I found
[Dancer::Plugin::Memcached](cpan) which had a pretty nice
interface, but was unfortunately using a backend that isn't
available on my server. So I thought: "how hard can it be to write
a similar plugin that interfaces with [CHI](cpan)?".

Not very hard, it turns out, and a few hours later
[Dancer::Plugin::Cache](cpan) was born.

## Writing a Plugin

All the tools you need to write a Dancer plugin are 
contained in he helper module 
[Dancer::Plugin](http://search.cpan.org/dist/Dancer/lib/Dancer/Plugin.pm).
To invoke them, you just need to 'use' `Dancer::Plugin` within your module --
all the inheritance stuff is taken care of behind the curtain:

```perl
package Dancer::Plugin::Cache;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;
```


With this simple invocation, we have now at our
disposal the three functions that module provides: `register`, 
`plugin_setting` and `register_plugin`. 

### register()

`register()` is the most importance of the bunch, and defines keywords that are imported 
in the application's namespace when the plugin is used. For example, for providing
a '`cache`' keyword returning the `CHI` instance of the application, what we
need to do is:

```perl
register cache => sub {
    state $cache = CHI->new(%{ plugin_setting() });
    return $cache;
};
```

Which is not high magic, mind you; we're only providing a wrapper around 
the underlaying cache object.

The fun, however, doesn't have to end there. Such keywords can be used to
inject some new route behaviors to the application as well:

```perl
register check_page_cache => sub {
    before sub {
        halt cache()->get(request->{path_info});
    };  
};
```

In this case, calling 'check_page_cache' in the application will 
enable a check that, if available, will return the cached output of a route 
instead of executing it.

Also, since the calls to `register` are done at runtime, we can also 
indulge in the kind of fun that [Moose](cpan) allows and programmatically
create routes:

```perl
# create a bunch of helper functions
for my $method ( qw/ set get clear compute / ) {
    register 'cache_'.$method => sub {
        return cache()->$method( @_ );
    }
}
```

### plugin_setting()

If you noticed, I already used `plugin_setting()` in the definition of the
'`cache`' keyword.  It has a very simple function: it returns the
configuration hash related to the current plugin. For `Dancer::Plugin::Cache`,
it'll return whatever is contained within `config->{plugins}{Cache}`, which in
the YAML configuration file will be, e.g.:

```yaml
plugins:
Cache:
    driver: Memory
    global: 1
```

### register_plugin()

This last function is the final *amen* of the plugin that tells Dancer to go
forth and register it with the application. There are no knobs or settings
that we have to be aware of. It just needs to be there at the end of the 
plugin module, and everything will be peachy.

```perl
register_plugin;
1;

__END__
```

### Ready to Rock

And that's it, we are ready to use our plugin (see the source
of [Dancer::Plugin::Cache](cpan) for the full working
example):

```perl
package MyApp;

use Dancer ':syntax';
use Dancer::Plugin::Cache;

# caching pages' response
check_page_cache;

# this page will be automatically cached
get '/cache_me' => sub {
    cache_page template 'foo';
};

# but not this one
get '/uncached' => sub {
    template 'bar';
};

# using our helper functions

get '/clear' => sub {
    cache_clear;
};

put '/stash' => sub {
    cache_set secret_stash => request->body;
};

get '/stash' => sub {
    return cache_get 'secret_stash';
};

# using the cache directly

get '/something' => sub {
    my $thingy = cache->compute( 'thingy', sub { compute_thingy() } );

    return template 'foo' => { thingy => $thingy };
};
```


A last, small detail that is good to know: the plugin must be 'use'd in
every module of the app where you want to access its keywords.


