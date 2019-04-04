---
url: metacpan-recommendations
created: 2013-03-14
tags:
    - perl
    - MetaCPAN
---

# MetaCPAN Recommendations: A Proposed Battleplan

> *Update:* Tim Bunce also wrote a blog entry laying out his 
> [own vision](http://blog.timbunce.org/2013/03/10/suggested-alternatives-as-a-metacpan-feature/)
> for the recommendation mechanisms.

The periodic pressure point of CPAN having a plethora of modules with 
overlapping functionality and no real efficient way to choose between them
(arguably, there is [cpanratings](http://cpanratings.perl.org)) surfaced 
again. A long time ago, I 
[drafted a possible recommendation
system](http://babyl.dyndns.org/techblog/entry/cpanvote-is-live),
and despite the time that passed, I still believe that I was unto something
(which either hint at truly a worthwhile core idea, or deep delusion. Which
one it is? Only time, and the blog comments, will tell.).
But, y'know, time being scarce and all that, I let the whole thing go to
sleep. Now, however, feels like a good time to take a deep breath, clench my
teeth, jut my jaw forward and have another go at it.

## The CPANvote mechanism, revisited

MetaCPAN, bless its magnificent little heart, took care of the voting 
part of things already. So we can ignore all the voting stuff from the old
cpanvote and concentrate on the recommendation part. Which leave us with a
very simple core feature:

> Logged in MetaCPAN users should have the ability to recommend an alternative
> to any distribution. 

Just like that. For example, I should be able to go to the
[Path::Class](cpan) page and recommend [Path::Tiny](cpan)
as an alternative. Nothing more, nothing less. And then the webpages of the
various distribution would display the tally of their alternatives.

Sidenote: at first I was also considering the possibility to add a small note
to the recommendation, but finally decided the (initial) system is probably
best without. In part because simpler is better, but mostly for the political
aspect of the thing. No matter how gently we do it, a recommendation system
will always be a delicate affair. And in that optic, keeping things as spartan
and neutral as possible is probably a good tactic. The same logic goes in the
'recommended alternative' nomenclature, which only says that the author
recommends B over A, but without any overbearing implicit sense of conveyed superiority of one
over the other. 

Aaaanyway, that's my proposition. So, now, what needs to be done for it to
happen? Three things.

## First thing: Carve a space for the recommendations in the MetaCPAN backend

Basically, the MetaCPAN database needs to have a new list of recommendations
(recommended dist + who made the recommendation ) attached to each
distribution.

Should be easy to do. Current problem: I'm an Elasticsearch n00b, and don't
have the keys to MetaCPAN's backstore. Current plan of attack: contact the
MetaCPAN overlords, and lobby with the best puppy eyes I can muster. 

## Second Thing: Implement the front-end recommendation input

Basically, if you're logged in on MetaCPAN, a 'recommend alternative' button
should be seen beside the '+1'. Click on the button, and a text input appears
to enter the recommended distribution (bonus points for an auto-complete like
the main MetaCPAN search input). Recommendation done triggers an ajax call
that registers it to the backend (open question: should a recommendation
automatically +1 the recommended dist?). Subsequent views by the user should
have a modified 'recommend alternative' to make clear that they recommended 
something else (just like the '+1' looks different if you clicked on it).

## Third Thing: Show the recommendations

On dist pages, probably above the 'Dependencies' widget on the right side,
have a 'Recommended alternatives' of the format:

    Acme::Bleach    (Damian Conway and 6 others)
    Acme::EyeDrops  (Andrew Savigne and 3 others)
    AAAAAAAAAA      (Yanick Champoux)

## Enough Talk, Let's Do It

Actually, we still need to talk. Amongst other things, I *do* have to check
with the MetaCPAN folks if they agree with the plan. While I think they
will, it is fully their right to shake their heads and go "oh sweet $diety, 
noooo...". 

But assuming that they don't massively facepalm at the idea, 
and if you want to help, drop me a line. Things #2 and #3 are (fairly)
straight-forward, and can easily be stubbed in without having #1 done. Just
fork [metacpan-web](https://github.com/CPAN-API/metacpan-web), and get
cracking.

