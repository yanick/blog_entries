---
title: Dancing the Haka
url: haka
format: markdown
created: 24 Nov 2011
tags:
    - Perl
    - Haka
    - Dancer
---

At $work me and my colleages want to set up a LAN
radio station, so that we can all groove to the same 
soundtrack. 

To make things interesting, we want to be able
to dynamically add songs to the playlist. From any machine.

And since I don't really have time to do something like that,
I'm setting myself a deadline of one evening to get it running.

Got it? Good. For it's time to rip our shirts. And dance the Haka.

## Basic design

Our app will have one '`collection`' directory that is
going to contain all mp3s. 

It will also have a '`playlist`' directory. Each file of that directory is
going to contain the path to a song to play, and they are going to be played 
in the alphanumerical order of their filenames.

And that's it.

## Choose a streaming server

Of course, it'd be insane to reimplement a streaming server from 
scratch. So I looked at the offerings out there, and settled on
[icecast2](http://www.icecast.org). Under Ubuntu, the server
installs without any itch, and the default configuration is 
Good Enough(tm) for what I need. Excellent.

But the icecast2 server also needs the streamer for our mp3s.
This is going to be taken care of by [ices0](http://www.icecast.org/ices.php).
That one has to be compiled manually, but it's no big hardship. 

## Reading the playlist

*ices0* can get its playlist different ways. One of them, **ah AH**, is via a 
Perl script. So let's leverage that:

<galuga_code code="perl">ices.pm</galuga_code>

Nothing too fancy there. We just pick the first entry in the playlist
(and delete it so that we don't pick it next time) or, if there is no
playlist items remaining, get a random song from the collection. 

## Wrapping it in a web app

If we only wanted the streaming server, we'd be done. But we also want
peeps to submit new songs. For that, a web application is the 
best no fuss no muss approach. And since we're talking of the Haka here,
you just know our framework has to be Dancer.

Since we're going to go have a web app, why not have it deal with 
the setting and termination of the `ices0` streamer?  

<galuga_code code="perl">haka_ices.pm</galuga_code>

There we go. Our app now create the `ices0` config file out of
its own configuration, and launch the streamer as a forked 
process that is going to be reaped as we eventually exit. All nice
and encapsulated.

## The web application proper

For this first iteration of the project, we don't need much:

* The index page '`/`', redirecting to the icecast stream.

* a '`/collection`' page to push new songs to the collection (and add then to
the playlist).

* a '`/collection/*song*`' page to check if a song is in the collection.

* a '`/playlist`' page to add an already available song to the playlist.

And that is done via 

<galuga_code code="perl">haka_actions.pm</galuga_code>

## Client to upload songs

Having a web form to upload the songs one by one would be onerous. 
A little client script would be much better. Something with which you could do

    #syntax: bash
    $ haka_add.pl http://localhost:3000 song1.mp3 song2.mp3 ...

It would be even better if that utility would check if songs are already
present on the server and, if so, only add them to the playlist.

<galuga_code code="perl">haka_add.pl</galuga_code>

That wasn't so hard, was it?

## Waewae takahia kia kino!

And there we are. It's a raw app, with no fancy interface. But it's a working, dynamic,
shared radio station. Hacked together in 3 hours. 

Can we say
*Tēnei te tangata pūhuruhuru*?

As usual, if you want to play and experiment, the code is [on
Github](https://github.com/yanick/haka).  


