---
created: 2011-05-08
tags:
    - Perl
    - Dancer
---

# "Codename: Yanick in Black - Contributing to Other Peeps's Modules"

<div style="float: right; padding: 5px;">

![Men in Black](./files/yanick_in_black.png)

</div>

First of all, sorry for the delay of blog entry; only today
are my arms slowly breaking away from the spasms of Wallace-like
hand wiggling of glee enough to let me write those lines.

A little background information: a few months back, the
core [Dancer][1] folks decided to codename their releases
based on the names of contributors to the project. Thus,
release 1.3020 was known as "The Schwern Cometh", in honor of 
[Michael G. Schwern][2]. Then came release 1.3030, "Silence
of the ambs", for [Alberto Simões][3].

And on last May Day came release 1.3040. Codename? "Yanick in Black".

To say that I am surprised would be an understatement. To hazard that
I'm honored would grossly underestimate the truth. To postulate that 
such a thing would buy my undying loyalty and guarantee that my
trickle of patches would not dwindle anytime soon would... probably 
hit close to the dark, covert motives plans of the Dance Crew. ;-)

So I take this opportunity to return the favor to the Dancer Cabal,
and thank them for not only giving us a web framework that seriously
rock, but also to make it such a successful, vibrant and *fun* community 
project. It takes lots of brain to achieve the first, but it takes
oodles of wisdom to maintain the second. 

And since writing a blog entry sorely to talk about a software
release bearing my name would be slightly... ah... 
self-serving (and we couldn't have that in a blog, now, could we?), 
I thought to expand a little bit on the topic and 
discuss why I am contributing to other peoples' modules, and
how I usually go about it.

## Why Contributing to Other Peeps' Modules?

### Résumé Schmésumé, the Proof is in the Pudding

Mind you, it's not one of my top reasons to contribute 
to other peeps's code, but it's one which the bottom-line
can hardly be argued with. 

If you apply to be a bouncer at the Death Panda Klub, it's nice
to say that you have a black belt in taekwondo. But having 
calluses on your knuckles, tattoos of howling gorillas on your earlobes
and a scar running from your scalp 
to your chin with beer bottle shards still embedded in it? That's going 
to give you serious street creds. 

Likewise, it's good to say that, yeah, you know about *Module::Foo*. But to be able to say "actually, why
don't you open the Changelog and look at the contributors to see if 
you spot any familiar name"? That's always a killer. 

### Get Exposed to Code, the Same Way Godzilla Got Exposed to Radiations 

Looking under the hood of modules is a heck of an educative experience.
Of course, quality varies from one module to the other, but regardless
of their status of example or counter-example, they do expose you to
a large gamut of styles and convention. Which, ultimately, will turn you
into a special op capable of dropping into any kind of environment and
make it yours at will -- which is  the one skill that is the most
likely to keep you sane in the years to come. Trust me on that one.

### Walk with the masters

Contributing to a module means having to work with, at least,
its primary maintainer. Typically, maintainers are happy to receive
patches and -- if needed -- will either tweak them to fit within the general
architecture of the module, or give you pointers on how to do it yourself.
As, usually, those peeps are not the chopped liver of the CPAN
ecosystem, this is yet another golden vector for learning. And not only Perl
learning, mind you. Chances are you'll learn a thing or two about code
maintenance, release cycles and review procedures as well.

###  Have Your Itch Go Viral

While it's always possible to have your own code work around
rough edges of another module, to actually submit a patch 
means that, above and beyond not having to play twister to get your job
done:

1. the burden of making sure the desired functionality keep working in future 
releases has been pushed to the other module. Which means less job for you!

2. you subtly steered the general behavior of the module to fit your needs. 
Do it enough, and modules you had your fingers on will begin to feel like
real comfortable slippers. 

3. You also brought your itch to attention of a lot of peoples. Smart peoples.
Peoples that, if your initially idea was good, will run with it and make it
blossom into breath-taking awesomeness.

### Networking, Baby

Submitting patches means interacting with the contributors of a project.
And that usually mean being introduced to parts of the Perl community,
which in turn means forging alliances, friendships, and just getting acquainted
with a lot of good coders. This is how all good world domination journey
begin...

### And it's Just so Bloody Easy

In these days of [GitHub][4], and of utilities like
[Git::CPAN::Patch](cpan), the mechanics of 
contributing to a module have been brought to a ridiculously low
level. Five minutes is often all it takes to share your patch
with the world. 

The patches themselves don't have to be hard to come up with either.
Patches can be for the core code, of course, but they can also be
aimed at the documentation or test cases. Trust me, whatever are your
skill set, chances are that you can help your favorite module, in 
some way or other.

## Rules of conduct when contributing to a module

Assuming that I succeeded into priming you to
go forth and contribute to your favorite modules,
here are a few rules that I try to obey, and that
served me well in the past.

### Rule #1: the Maintainer's Will is Law

The first and most important rule. Whatever you do,
always remember that when you are contributing to somebody else's
code, you are a guest in somebody else's house. This
means that, at the end, they call the shoots.  They don't want 
their code to be [Moose](cpan)-based? Then so be it. They desire
the module to be Perl 5.6-compatible? You'll have to keep that 'given/when' 
at bay.

The rule goes further. While each patch is, in a way, a gift, one must
never forget that the maintainer has the right to say 
"thanks, but no thanks".

### Rule #2: When in Rome...

Could be seen as a corollary of rule #1. Basically, try to respect
the coding style and conventions of the codebase.  Sometimes it can 
be hard as you might not agree with some of them. ... No, sorry. 
Sometimes, it **will** be hard, as you **will** not agree with some of them. 
But remember: you are a guest, and the final decision will not be yours. 

Not to say that you can't try to convince the maintainer that there is 
a better way of doing things -- just make sure to do it with the required
humility, and being ready to let go if a magic conversion doesn't happen.

### Rule #3: Keep Patches Small and Targeted

Great way to increase the chances of a patch to get accepted. A patch can have
the perfect fix for a given function, but if the patch author also decided to
helpfully change all variable names to camel case... well, let's just say the
patch's appeal is just not the same.

### Rule #4: Toys Should Come With Batteries Included

Here, that means test cases and documentation. Not only this is
the stuff that no-one like to do for somebody else, but they are 
a good way to clearly show what you are fixing, and what's the difference
from the outside.

### Rule #5: Dare to Have Fun

Last rule: dare! Dare to poke maintainers and ask them what they think of 
your latest wacky idea, or if they could use some help with something. Perl
peeps are, in general, a friendly bunch, and chances are that you will find
that you opened a door to a lot of educating, rewarding, unabashed fun. 



[1]: http://perldancer.org
[2]: http://search.cpan.org/~mschwern/
[3]: http://search.cpan.org/~ambs/
[4]: http://github.com
