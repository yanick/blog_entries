---
created: 2010-12-18
last_updated: 3 Jan 2011
tags:
    - Perl
    - Catalyst
    - Catalyst::Plugin::VersionedURI
    - caching
    - web development
    - Apache
---

#Getting Around Expiration Dates via Reincarnation (and Catalyst)

**EDIT**: as Alexander Hartmaier pointed out in the comments, the version
can also be added as a parameter (http://foo.com/static/avatar.png?v=1.2.3),
which nicely remove the need to juggle things back into place 
on the web server side. 


Web applications typically have a bunch of static files -- images, css and
javascript, that kind of stuff -- that almost never change. For all but the
simplest apps, it's usually a good idea to let the browser know that it can
cache and reuse those files, so that we can all save a little bit of bandwidth
and get things moving a wee bit faster.  For that, we have the HTTP Expires
header:

```
&lt;Directory /home/myapp/static>
        ExpiresActive on
        ExpiresDefault "access plus 1 year"
&lt;/Directory>
```

This approach is flawless for files that will never, ever change.
 But for files that *almost* never change, it's
a little bit more tricky.  No matter how big or small you pick your `Expires` duration,
any update of the file can potentially impact users who will still use, for
some time, the cached content.

A usual solution to that problem is to have updated files have different urls.
For example, instead of having `http://foo.com/static/avatar.png`, we 
add a version number to the path such that a first version of the application
would use `http://foo.com/static/v1/avatar.png`, a second version  
`http://foo.com/static/v2/avatar.png`, and so on and so forth.
The browsers see different urls, so everything is loaded anew each time
the version goes up.

Of course, creating a new 'v<i>something</i>' sub-directory for each release of the
app is not very appealing. Nor is it necessary; it's not because
the url has to look different that, under the hood, it can't be the same.
We can augment our Apache configuration with a little path legerdemain
like so:

```
&lt;Directory /home/myapp/static>
        RewriteEngine on
        RewriteRule ^v[0123456789._]+/(.*)$ /myapp/static/$1 [PT]

        ExpiresActive on
        ExpiresDefault "access plus 1 year"
&lt;/Directory>
```

And now, browser-side, we have it all. As long as the app isn't upgraded, the
static files are set to never expire. And as soon we have a new release, 
that caching will be bypassed by the grace of a new set of urls.

Those shenanigans, however, come with a logistic price; the code of application
has to generate those versioned paths.  Where, before, we had

```perl
$c->uri_for( '/static/foo.png' );
```

we must now write

```perl
$c->uri_for( '/static/v' . $c->VERSION . '/foo.png' );
```

Blerg. If we want to do that for more than a handful of uris, that's cumbersome.
So... why not write a very small plugin to insert that versioned element in
the path for us?

## Catalyst::Plugin::VersionedURI

The task we want the plugin to perform is quite simple: intercept calls
to `uri_for` and, if the uri matches a set of paths we know to be
static, we supplement it with a versioned component. Pleasantly enough, the code
for the plugin proves to be as concise as the requirements:

<galuga_code code="Perl">plugin.pl</galuga_code>

Once this is done, we just have to add a stanza to our configuration file:

```
&lt;VersionedURI>
    uri  static/
&lt;/VersionedURI>
```

And, voilà, our application is now issuing versioned paths.

## You broke my development server, you insensitive clod!

While this is working fine with the Apache front-end, it's going to
seriously cramp your style if you use, as I do, the *myapp*_server standalone
server. The obvious solution is, well, obvious: remove the `VersionedURI`
configuration stanza from your development configuration file. 

If, for
whatever reason, you absolutly want your application to deal  with the
versioned paths with or without Apache, you'll have to add a controller 
to strip away what we toiled to shoe-horn in:

<galuga_code code="Perl">controller.pl</galuga_code>

That's, admittedly, not the most elegant way of doing things -- there must be a
way to programmatically add actions in a less gruesome way -- but it'll do in a
pinch.

## Where can I get the code?

On [GitHub](http://github.com/yanick/Catalyst-Plugin-VersionedURI), as usual. Glad you asked. :-)
Tuits providing, it should also be pushed to CPAN sometime within the next couple of weeks.

