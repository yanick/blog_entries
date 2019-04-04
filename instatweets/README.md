---
title: Instant Tweets for Any Website
url: instatweets
format: markdown
created: 14 Mar 2011
tags:
    - Perl
    - Dancer
    - Twitter
    - Guerilla Hack Chronicles
---

Say there a website you would like to tweet directly from. Not via a
Twitter client, not using a service like [Yoolink][1], not through a Firefox
plugin. No, you really want to be able to have a honest to God "Tweet this" input
field on the website itself.  It's a strange requirement, for sure, but it's
a mission that I've be given a few days ago.  Here's how I dealt with it.

[1]: http://www.yoolink.to/

## Step 1: Register the Twitter Application

My first step was to visit the [Twitter dev site][2] and register an
application, so that the twitter add-on I'm creating will be able
to authenticate with the Twitter web service (and ultimately be able to
relay the tweets I'll be feeding it).  Following the instructions provided on
the site, it only takes a few seconds to have a new application created, and 
its credentials in our grubby little hands. 

[2]: http://dev.twitter.com/

## Step 2:  The Authentication / Posting Backend

While it *could* be possible to come up with a JavaScript-only solution for our 
task, it would mean that the application's credentials would be contained
within the JavaScript, and thus visible to anyone bothering to peek at the
code. Security-wise, that's majorly icky.  So we need a small back-end to take care
of the OAuth authentication business.  For such a simple task, I called
upon the might of [Dancer](cpan):

<galuga_code code="Perl">backend.pm</galuga_code>

Most of the work is done by [Dancer::Plugin::Auth::Twitter](cpan)
behind the scene. To have the user authenticated by Twitter, we 
have to hit the '/authenticate' action, which will automatically redirect us to 
the Twitter authentication page. If the user confirms that he or she trust the
application, Twitter will bounce back to our '/' action, which will
automatically stash the user's tokens in his or her session and complete
the Great Circle of Authentication and redirect the user on the page where all
the fuss started. 

Two points of interest here. 

First, it's good to remember that what's stored
on our side is not the user's Twitters credentials, but rather authentication
tokens that can only work in tandem with our application's token.  Which means
that even if our application token was leaked out (which we still don't want
to happen, mind you), the user's wouldn't be totally vulnerable -- he or she
could revoke permissions given to our application without impacting its global
identity.

Second, although I've used [Dancer::Session::YAML](cpan) for 
convenience here, I could have made the backend lighter still and 
push all the session information to the browser itself by using
[Dancer::Session::Cookie](cpan).

## Step 3: Shoe-horn the Twitter Interface on the Page

For the final part, I used my favorite page-mucker agent, Greasemonkey, 
enhanced with jQuery to make the mucking as painless as possible. 

<galuga_code code="plain">gmscript.javascript</galuga_code>

We now have a Twitter box that will 
appears as soon as we click on the Tweet-bird (and neatly re-hide itself if we
click again), will check all by itself if we are authenticated (and let us
know of the link to remedy the situation if we aren't). We also have the
classic auto-updated character counter, and thanks to a nice
jQuery plugin, the tweet input box resizes itself as we type more text. All of
that in 80-something lines.

A little note here too: if you look at all the code on GitHub, you'll see that the call to 'gm_xhr_bridge()' 
leds to a little more code fudging jQuery's `xhr` object to use the
'GM_xmlhttpRequest', which magically allows to do cross-site scripting. Not
very honorable, perhaps,  but incredibly useful to know.  This being said, 
the problem of cross-site scripting could also have been dealt with using JSONP
callbacks, which in this instance could have been added to the overall
solution in a few lines (thanks to Dancer).

## And the Result...

... if applied to good ol' `search.cpan.org`:

![CPAN Twitterized](__ENTRY_DIR__/cpan-twitter.png)

All the code, as usual, is available on [GitHub][3].

[3]: https://github.com/yanick/instatweets

