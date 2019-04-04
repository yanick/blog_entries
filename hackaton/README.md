---
title: Hackscape From New York
url: nyc-2015-hackaton
format: markdown
created: 2015-05-04
tags:
    - Perl
    - hackaton
---

"Would you consider coming for the [New York Hackaton][nyh] in May?" was the 
question Jim Keenan sent my way a few weeks back. 

The [New York Perl Mongers][nypm], he
informed me, had formed an alliance  with Bloomberg. 
Not only the Hackaton was going to be hosted at Bloomberg's New York office, but
the wheels had been
set in motion to invite a few peeps from outside town. And, for reasons
defying Euclidean logic and post-Boschian sensibilities, 
my name was on that prospective guest list.

So, anyway, the question was "would you entertain the idea of coming?", and
the answer went something like "hell yeah".

Fast-forward to last Saturday, and there I was, stepping in my very first
Hackaton ever. 

## Hackatons: only for demi-gods, or also for mere humans?

I was always curious about Hackatons, and how I'd fare in such an event.
The thing is, I don't think fast on my feet. My usual modus operandi
consists of taking in requirements and retreat in darkness where lots of
time, unglorious head-banging and foul
cursing would slowly and painfully hammer the raw ore of specs
into precious features -- we could call it Nibelung-based development.
So what would happen if I was thrown in a room and tried to be productive
outside of my familiar software forge?

As it turns out, it's not as hard as it sounds. The trick is to stack the 
deck in your favor. 

First, you have to know what type of hackaton lies ahead.
Some of them mean seriously business and /are/ indeed for demi-gods, but most
of them accomodate hackers of all levels. 

Second, it's always a good idea to 
pick the tasks you want to work on in advance. Not
only it gives you a concrete sense of what you want to accomplish for the day,
but it allows for doing some preparation work such that you don't find
yourself having to do some Mentat-grade thinking on Hackaton-day or, worse, 
find the task hamstrung within minutes because of unforeseen dependencies.

Talking of dependencies, this brings us to: Third, making sure that your
laptop is in sync with your usual development platform. And I realize I date
myself by saying that because most people's main workhorse /is/ their laptop.
But for dinosaurs like me, booting their laptop for the first time in ages and
realizing that their vim profile has spiderwebs, color themes turned yellow
and well-used utilities like `tmux` and `watcher` are nowhere to be found can
be... let's say "aggravating".

Fourth, and finally: although people might claim Hackatons are all about the
destination, in reality, it's mostly about the journey.  Mind you, it's
awfully nice to have
some results to show at the end of the day, but the important part is mostly
to advance a little bit, socialize/spread ideas a little bit, and largely
just let the synergic ether flow through you and recharge the batteries for
the weeks and months ahead.

So, yeah, I guess what I'm trying to say here, is that no matter what's your 
working style, no matter how neophytish or gurulous you are, Hackatons are
worth trying. 

## So you say, but how was /that/ Hackaton?

The Hackaton was *grand*, and I had a blast. 

Social-wise, it was awesome to
meet YAPC buddies and Twitter friends. I was finally able to put a face on
MetaCPAN's mastermind Olaf, I managed (to my everlasting shame) not to
immediately recognize David Farrell (in that way he joins Tommy 
"You have a beard!" Stanton), discussed magic tomato socks with Auggie,
and had Ricardo Signes heap movies on my must-see watch-list, cocktails on my
must-drink list, and ice creams on my must-churn list.

Tech-wise, I daresay I did good. I was part of the Mini-CPAN PR track, and
put to rest a long-standing [Dancer1 session performance bug][dbug].
Then, because after all I was there to corrupt other minds, I slithered 
near a wonderful chap named Charlie and guided him through his first
[Dancer2][d2] PR. We then went on to begin moving
[Text::Xslate](cpan:module/Text::Xslate) from [Mouse to Moo][moo] -- and while
the task is nowhere finished, a solid dent has been done in it. 

So, yeah, it's safe to say that a good time was had by all. Personally, I owe
a big thank to Bloomberg (and its agent for this event, Kevin
Fleming) as well as for Jim and Charlie to have invited me to the event. They
all made my first foray into Hackaton an awesome one.

Now, I should see if I could coax my Ottawa.pm brethen into something
similar...


[moo]: https://github.com/yanick/p5-Text-Xslate/tree/moo
[d2]: https://github.com/PerlDancer/Dancer2/pull/898
[dbug]: https://github.com/PerlDancer/Dancer/issues/992
[nyh]: http://www.meetup.com/The-New-York-Perl-Meetup-Group/events/221319780/
[nypm]: http://www.meetup.com/The-New-York-Perl-Meetup-Group/
