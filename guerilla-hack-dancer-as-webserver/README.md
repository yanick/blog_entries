---
url: dancer-as-web-server
format: markdown
created: 2011-03-13
last_updated: 16 Mar 2011
tags:
    - Perl
    - Dancer
    - Guerilla Hack Chronicles
    - Python
    - Plack
    - Plack::App::Directory
---

# The Guerilla Hack Chronicles: Dancer as a Ad-Hoc Web Server

**edit (March 14th, 2011):** even better suggestions from the comments have been 
added at the end of the entry.

Let's say you want to serve static http content from
a machine. The sensible thing to do would be to
install Apache/Nginx/Lighttp.

But let's say -- because of insane
configuration, red tapes, cruel whims of the gods -- that you can't
do the sensible thing.

Fortunately, there's a few aces you can pull off your sleeve.

One of them is to use <a href="http://search.cpan.org/dist/Dancer">Dancer</a>
as a spur-of-the-moment bare bone web server:

<pre code="bash">
$ dancer -a proxy
$ cd proxy
$ rm -fr public/ &amp;&amp; ln -s /path/to/share public
$ ./bin/app.pl -p 8086
</pre>

With that, we now have a single-threaded web server listening on port 8086 serving
the files of <code>/path/to/share</code>.

If you need it to be more beefy, as in act like a real web server and
deal with concurent requests, just plack it up:

<pre code="bash">
$ plackup bin/app.pl -p 8086
</pre>

## Meanwhile, in the Comment Section...

noah has been suggesting a Python variant using its core module
[simpleHTTPServer](http://docs.python.org/library/simplehttpserver.html):

    $ python -mSimpleHTTPServer 

[Aristotle](http://plasmasturm.org/), meanwhile, has summoned the power 
of [Plack::App::Directory](cpan), which has the added bonus of
generating auto-indexes:

    $ plackup -MPlack::App::Directory -e'Plack::App::Directory->to_app'

That was going straight into my list of aliases as

<pre code="bash">
alias instaweb="plackup -MPlack::App::Directory -e'Plack::App::Directory->to_app'"</pre>
    
but [Pedro Melo](http://www.simplicidade.org/notes/) chimed in and pointed
our attention to [App::HTTPThis](cpan), which uses [Plack::App::Directory](cpan)
under the hood and provides the utility '`http_this`'. With it, sharing a directory via http
is as simple as running

<pre code="bash">
$ cd /path/to/dir/we/wanna/share
$ http_this
</pre>

Can things possibly get any sweeter?
