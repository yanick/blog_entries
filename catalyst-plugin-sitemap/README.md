---
created: 2010-09-27
tags:
    - Perl
    - Catalyst
    - Catalyst::Plugin::Sitemap
    - Search::Sitemap
---

# Catalyst::Plugin::Sitemap

I hadn't planned on writing this. In fact, I positively don't have the time to
write this. But, sometimes, the only mistake a man has to make is to pause one second
and wonders <i>hey, wouldn't be cool to have something that auto-generates the sitemap of a Catalyst app?</i>
And then **BAM!** The yak
jumps out of nowhere, hangs to the poor sod's t-shirt with all hooves and
forcefully moos "shave me, *shaaaave me*" until the silly git succumbs to the
pressure. 

Oh well. On the sunny side, I've now written my very first Catalyst plugin, and
that's going to be something useful for
[Galuga](http://babyl.dyndns.org/techblog/entry/galuga).

As I don't have a lot of time, I'll be succint. As you've doubtlessly gathered
by now, the name of the 
game is *Catalyst::Plugin::Sitemap*. It's on [Github](http://github.com/yanick/Catalyst-Plugin-Sitemap), but 
it's not CPANized yet.

To use it, add the plugin to your Catalyst app main module:

```perl
use Catalyst qw/ 
    Sitemap 
/;
```

Then, use the sub attribute *:Sitemap* to tag actions for which you want an
entry in the sitemap. The attribute can be called different ways:


```perl
    # bare attribute, add the uri for the action

sub alone :Local :Sitemap { 
    ...
}

    # with the priority of the sitemap entry

sub with_priority :Local :Sitemap(0.75) { 
}

    # with desired sitemap attributes
    # see Search::Sitemap for the full list

sub with_args :Local 
        :Sitemap( lastmod => 2010-09-27, changefreq => daily ) {
}

    # with '*', calls the function '&lt;action>_sitemap'
    # with the arguments ( $controller, $c, $sitemap ) 

sub with_function :Local :Sitemap(*) { }

sub with_function_sitemap {
    $_[2]->add( 'http://localhost/with_function' );
}
```


And that's it.  Your catalyst application now has a *sitemap()* method that
harvest all those entries and returns a [Search::Sitemap](cpan) object. 

```perl
sub sitemap : Path('/sitemap') {
    my ( $self, $c ) = @_;

    $c->res->body( $c->sitemap->xml );
}
```

That action, coupled with the ones defined above, would give this sitemap:

```xml
 &lt;urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
 &lt;url>
 &lt;loc>http://localhost/root/with_priority&lt;/loc>
 &lt;priority>0.75&lt;/priority>
 &lt;/url>
 &lt;url>
 &lt;loc>http://localhost/root/alone&lt;/loc>
 &lt;/url>
 &lt;url>
 &lt;loc>http://localhost/root/with_function&lt;/loc>
 &lt;/url>
 &lt;url>
 &lt;loc>http://localhost/root/with_args&lt;/loc>
 &lt;lastmod>2010-09-27&lt;/lastmod>
 &lt;changefreq>daily&lt;/changefreq>
 &lt;/url>
 &lt;/urlset>
```

Right now, the *Search::Sitemap* object is re-created each time the method is
called. The next time I have some rount tuit, I plan to provide the option to 
also just create it once.
