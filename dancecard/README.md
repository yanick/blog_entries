---
title: A New Year, a New Dancecard
url: dancecard
format: markdown
created: 3 Jan 2014
tags:
    - Perl
    - dancecard
---

First thing first: Happy New Year y'all! Health, happiness, and all that jazz to each and
everyone of youses!

So the Holidays are over -- or almost over, if you are one of the few lucky souls.
Which means that we have to get back into the saddle. Considering that, ahem, some
of us have just fallen off the grid and into the eggnog for the last two
weeks, that's easier said than done. In order to jog those hacking muscles back into
shape, I decided to revisit an idea that I outlined in the Holidays of 2012:
[dancecard](http://advent.perldancer.org/2012/10).

To recap, when I start a new [Dancer](cpan:release/Dancer) (or
[Catalyst](cpan:release/Catalyst-Runtime) application, I always
have to drop in the JavaScript libraries I'm using. That's tedious. 
Instead, I would like to have a little tool that invites chosen 
libraries to come and dance with the app. A kind of [Tanzkarte](http://en.wikipedia.org/wiki/Dance_card), if you will.

For the 2014 edition of this dancecard, I decided to take a slightly different
approach. Instead of keeping a repository of the libraries locally, I wanted
to be even lazier and simply
have a main registry that would point to the download location or the git
repository of the libraries.

For the moment I won't go into the details of the code. Mostly because I
pretty much banged the keyboard like a semi-hangover monkey for the last 2 hours,
and it reflects in the quality of the codebase. Let it just be said that the
git repo is at the [usual place](gh:yanick/App-Dancecard), and that I used
[MooseX::App](cpan:release/MooseX-App) to build the app.

So, what did those few hours of hacking gave me? Well, with the config file
`~/.dancecard/config.yaml`, which looks like

``` yaml
---
browser_command: firefox %s
libs:
    backbone:
        location: http://backbonejs.org/backbone.js
        website: http://backbonejs.org
        documentation: http://backbonejs.org
        dependencies:
            - underscore
    underscore:
        location: http://underscorejs.org/underscore.js
        website: http://underscorejs.org
        documentation: http://underscorejs.org
...
```

I can now get a list of all libraries I have at my disposal:

``` bash
$ dancecard list
INSTALLED LIBS
    no lib installed
AVAILABLE LIBS
    underscore
    bootstrap
    backbone
    slippy
    font-awesome
```

Of course, I can also install any of those. And... look Ma: dependencies are
handled automatically!

``` bash
$ dancecard install backbone
 backbone installed
 underscore installed
```

Something I also often do is peruse the online documentation of
those libraries. Noticed those 'documentation' urls in the yaml registry?
It's there so that I can do

``` bash
$ dancecard doc bacbone
```

and have the documentation page opened automatically in firefox. Or,
for maximum laziness, I can also do

``` bash
$ dancecard doc --installed
```

which will open the documentation url of every library found in the current
project.

## Next Steps

If anyone shows interest into the thing, I'll bundle the app for
CPAN consumption. As for features, things that I'll probably tackle
for my own use are:

* tags (no software is true software without tags nowadays), 
* virtual libraries (just as a mean to install a group of libraries in a single
go), 
* fish completion (I wuv the fish shell)
* cached local documentation ('cause hitting the 'Net each time I look for a
piece of documentation fills me with guilt)
* an online main registery of libraries,
* and whatever else I may think of.

