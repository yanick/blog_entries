---
created: 2011-02-20
tags:
    - Perl
    - Dancer
    - Slippy
    - S5
    - Pod::S5
    - websockets
---

# Chorus: a Fully Buzzword-Compliant Slide Webapp

Most of the time, I hack applications together because I have an itch
that badly needs scratching. But, sometimes, I also build up apps for 
the sake of trying out and experimenting with new technologies. The process
I'm following for those latter apps is what I call *Awesome Driven
Development*, or *A.D.D.* for short. Basically, I just let my 
[inner Hammy][1] take over and just go wild with the shiny.

[1]: http://overthehedgeblog.wordpress.com/2011/02/20/hammy-invents-hamnesday/

## Generate slides with Dancer, Markdown and Slippy

This [particular app][8] begins with the discovery of [Slippy][2], a jQuery-based
slide presentation system.  It seems a little more easier to use than 
[S5][3], which was up to now (with the help of [Pod::S5](cpan)) 
the best alternative I had found.

[2]: https://github.com/Seldaek/slippy
[3]: http://meyerweb.com/eric/tools/s5/

Of course, I don't want to write HTML by hand. That'd be positively medieval.
POD, I also found out with my use of `Pod::S5`, is not ideal either. Then,
why not use [Markdown][4], which serves me quite well for my blog?

[4]: http://daringfireball.net/projects/markdown/
[5]: http://www.perldancer.org

Also, instead of generating a static html version of the presentation, I'd
like it to be a web application. We're talking about a very simple application, here, 
so we'll use [Dancer](cpan). The code required
to get this puppy off the ground is, as one might suspect, minimal. The 
script itself looks like this:

<galuga_code code="Perl">chorus_1.pl</galuga_code>

And the HTML template (I'm using [Dancer::View::Mason](cpan)) like that:

<galuga_code code="xml">index_1.html</galuga_code>

Now all I have to do to get my slides up and running is

    $ chorus.pl my_prez.markdown

Excellent! 

## Share the bounty with the audience

But... wait a second. I'm using a web application to render my
slides, right? Why not share the fun with the audience?  Nothing easier. 
I'm passing the app's url to the template (although I could just as well
use JavaScript's `document.location`) and inject the information to the 
output:

<galuga_code code="xml">index_2.html</galuga_code>

With this, the url of `chorus` is automatically displayed and anybody
in the audience can access the slide deck.

Spiffy!

## Turn the audience into a chorus line

But... wait another second. Sure, the audience can see the slides, but wouldn't 
it be terminally cool if their display was synchronized with presenter's?
Let's say the application elects the first person to
connect as the master presenter, and everybody else as members of the
chorus. Then when the MC changes slide, the information should be
pushed to the chorus. Simple requirements, but how to implement them?

Enter [websockets][6].  The technology is bleeding-edge new, and looks dauting. But
by following the instructions given by [Dancer::Tutorial::WebSockets][6], 
and using [Twiggy](cpan) and  [Web::Hippie](cpan), it's surprisingly
easy.

[6]: http://en.wikipedia.org/wiki/WebSockets
[7]: http://search.cpan.org/~sukria/Dancer-1.3000_01/lib/Dancer/Tutorial/WebSockets.pod

Dancer-wise, what has to be done is to add `Web::Hippie` to the application,
and basically add two routes:

<galuga_code code="Perl">routes.pl</galuga_code>

Mind you, there are a few more details involved, which you can see
at the [GitHub repo of chorus][8], but not much. 

[8]: http://github.com/yanick/chorus

On the HTML template side, the added code is equally succint:

<galuga_code code="xml">index_3.html</galuga_code>

Tweaks also had to be brought to `Slippy` to make,
for example, the current slide number available. But only minor
stuff.

And we are done with the mechanics. With what we did, all members of the
audience can access the slide deck at will:

![Chorus, no websocket](__ENTRY_DIR__/chorus1.png)

And those with
a websocket-enabled browser (right now, that'd be *Google Chrome*
and *Firefox 4*) are given a little bit more toys to play with:

![Chorus, with websocket](__ENTRY_DIR__/chorus2.png)


Just remember: for the websockets to work, you have to use *Twiggy* 
as your Plack engine. But beside that, that's it. Our
Dancer-powered, Markdown-backed, jQuery-using websocketed application
has stepped out of science-fiction and is now a running reality.

Ain't it *awesome*?


