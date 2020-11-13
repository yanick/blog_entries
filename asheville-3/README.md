---
url: asheville-part-III
format: markdown
created: 2011-07-23
tags:
    - Perl
    - YAPC::NA
    - YAPC
    - Asheville
    - conference
---

# The Chronicles of Yanick: Escape from Asheville

Recap from our [previous](http://babyl.ca/techblog/asheville-part-I) 
[episodes](http://babyl.ca/techblog/asheville-part-II): 

A couple of weeks ago, I wake up, skeedaddle to a different country, meet some
wonderful people and let my brain soak up talk after talk for three days
straight. Lotsa fun all around.

## Everything Else 

The talks, of course, are only one facet of a conference. What happens
in-between in the hallways, at the pub or the breakfast table is equally 
important, and often equally enlightening.

### The Conference Dinner

There's already been a strong
[discussion](http://rjbs.manxome.org/rubric/entry/1898) going around about the
dinner and the auctions. In a nutshell, some people
found the auctions an overly long affair which, alas, encroached on
the social aspect of the dinner.  I have to agree on that. Don't get me
wrong: the auctions *were* entertaining, and I *did* have a grand time.  But it's
true that it would have been nice to have more time to just sit and chat.
And have some coffee. 
Chalk that one up against my inexperience of the YAPC
protocol, but I was fully expecting all three after the auction. Indeed, I was
periodically stealing loving glances at the upturned cup facing me 
on the table, thinking how it would presently be
filled with some delicious, hot tar-like beverage as soon the auctions 
would be over. But it was not to be, for as soon as the auctions were
concluded, *whoosh*, the whole room rose as if a single entity and
disappeared in record time, leaving nothing behind but me, clutching my
bone-dry cup with what could be best described as a slight quizzical expression.

### Knitting BOF

"Should have brought my hook." That's what I thought as
I realized that the lady sitting next to me had whipped out a project and
was serenely knitting while listening to the talk (as it turned out,
her husband was the Perl hacker, and she was just tagging along). 
Later, she told me that she saw another guy doing the same thing
in another session ([oylenshpeegul](https://github.com/oylenshpeegul),
perhaps?).  If nothing else, I'll join their ranks next time.
And perhaps try to organize a Knitting/Crochetting BOF to both discuss
how [Perl can purl](http://babyl.dyndns.org/techblog/entry/knitting-pattern),
and maybe share Perl-themed
[projects](http://www.flickr.com/photos/yenzie/5119001831/in/photostream).


### The Fat Comma Gains a Few Pounds

[Abigail](http://search.cpan.org/~abigail/) shared with us a new Perl "operator". What do you do when you want
to use the fat comma, but don't want its auto-quoting behavior? Well, 
add a little dangling bit to it, of course!

```perl
use strict;
use Data::Printer;

sub foo { 'bar' }

my %x = ( foo => 'quoted', foo ,=> 'not so' );

print p %x;
```


The logic twists the interpreter goes through to manage to Do The Right Thing
there are left as an exercise to the reader. As is the task to find a 
name for this new operator. Personally, I keep thinking of it as the
"fat comma (male specimen)", but that's.. uh... just a tad unsettling.

### Of Poultry Sacrifices and DBD::Oracle Installations

Judging by the number of times it was mentioned, poor [DBD::Oracle](cpan)
seems to be the poster child of hard-to-install modules.  One person, as I
recall, mentioned the necessity of chicken sacrifices to dark gods 
and bloody pentagrams for successful deployments. As the brand-new
maintainer of that  beast, I can only say that... errrr, well, yeah, I can see the point.

Between its `Makefile.PL` that tries to cover all the possible scenarios across multiple
platforms and architectures spanning the last two decades, and Oracle itself
that doesn't always make it easy, `DBD::Oracle` is a little bit of a
idiosyncratic singularity. But the good news is that I'm determined to improve
on that, and I'm sure a little bit of TLC is going to go a long way
toward decipherable outputs, DWIM configuration and sane documentation. We'll
not be able to turn `DBD::Oracle` from bad boy
to lovable rogue overnight, but if we play my cards right, it should get
better. It has to. Too many chickens' necks are on
the line.

### I Meet With Galuga's Userbase!

Or, as he's also known, [Tommy Stanton](http://tommystanton.com).
Tommy started to use [Galuga](https://github.com/yanick/Galuga) for his own blog a few months ago. 
A few customizations later, and his blog actually looks much better than mine.
Darn him.

We briefly discussed of the future of Galuga. Documentation is in
order. As is tidying the code (Galuga is one of those projects that
I use as an excuse to try new technologies, and it shows) and 
the architecture. Also looming big at the horizon is 
a port to [Dancer](cpan), more administration goodies
and maybe a use of [GitStore](cpan) to interface
with the blog entries. Oh yeah, and somewhere down the line 
there is the tricky question of how
to publish a web application on CPAN. All in all, lots of cool, fun stuff.
Loooots of it... Now, I just hope that my tuits reserves will be adequate.


### Roads to Glory (aka For the Love of Blog)

One thing the conference really reinforced 
for me is how useful and efficient blogging is
for information dissemination. To my great pleasure,
a few people *did* recognize my name throughout
the conference. In the majority of cases,
they knew me from my blog entries, either
because they see them bobbing up and down the 
Perl feed aggregators, or because *gasp*
they had adopted one of the tools I showcase there.
(we already covered Galuga's thriving community of one,
but I also discovered that somebody out there is
using [DPANneur](http://babyl.dyndns.org/techblog/entry/dpanneur-your-friendly-darkpancpan-proxy-corner-store), huzzah!)

What lesson can we draw from this, boys and girls?
Simply: if you want to make a name in the Perl community,
join mailing lists, hop on IRC, submit patches, 
attend conferences, go to  your local Perl Mongers's
meetings, and blog. Blog like hell.

It's easy, and thanks to [blogs.perl.org](http://blogs.perl.org),
you don't even have to worry about setting up 
a blog engine or website yourself. And the
great beauty of the medium is that, with
feed aggregators like 
[Perlsphere](http://perlsphere.net/) and [Perl Iron
Man](http://ironman.enlightenedperl.org/),
you don't have to be a Perl Elder God to 
reach a large audience.

Don't limit blog writing for 
Great World-Changing Revelations either.
See the Perl blogosphere
as an never-ending lightning talk
session. Tricks and syntax discussions,
no matter how simple, are a treasure trove for
beginners. That 30-something lines hack that saved you
a few minutes? It might be simple but I can assure
you that somebody out there never thought of it,
and will end up singing your praises when that same script
shave the same few minutes off their day. Even wishes,
musing and half-baked pieces of framework are good to share, as they are
apt to trigger discussions or, and this is the best,
draw the interest of people who are orders of magnitude smarter than
you are who are likely to grab the ball and run with it in ways you
would never have dreamed of.

[Git::CPAN::Patch](cpan) is a good example of blog-driven development.
First mentioned as a [list of manual steps by brian d foy](http://use.perl.org/~brian_d_foy/journal/37664),
it was [turned into a script](http://use.perl.org/~Yanick/journal/38180) by
your truly, which then got a full dose of [nothingmuch](http://search.cpan.org/~nuffin/)'s expert craftmanship. Eventually,
it would also be revisited by [Schwern](http://search.cpan.org/~mschwern/), who niftied it some more as
he was working on the guts of [Gitpan](https://github.com/gitpan).

The [Perldoc bash autocomplete](https://github.com/ap/perldoc-complete) is another good one. First mentioned
[as an aside](http://babyl.dyndns.org/techblog/entry/local-pod-browsing-using-podpomweb-via-the-cli), 
it tickled [Aristotle's fancy](http://blogs.perl.org/users/aristotle/2010/02/a-bash-completion-helper-for-perldoc.html), who cleaned it up and...
well, by now it's a tool that I could hardly live without.

There are many more examples, but the point is: you never
know what any given snippet of code is going to trigger (my 
personal crowning moment of awesome was when I cracked open
a certain book, and thought "geee, why is this code looks so famili--
*ooh...*"), but there's much to bet that it will trigger something.
So blog, friends. Blog till your fingers hurt.


### Mad Props to the YAPC Peeps

And I couldn't conclude without thanking the organizers
for an amazing job. A huge shout out also go to all attendees, for being
a real, honest-to-gawd *community*.  YAPC is as much a family reunion than
a conference, and by Joves, if I can do it, I'll sure be there next year. 

## The End

<div style="float: right; width: 200px;">
<div align="center" style=" margin-bottom: 1em;">
<img src="__ENTRY_DIR__/asheville_logo.png" alt="Asheville airport
logo"/></div>
<small><i>the red-hot plane with the trail of fire should
have tipped me off</i></small>
</div>

... or is it?  


By now, we are Thursday. My returning flight is in the late afternoon, which 
gives me the opportunity to wake up at a civilized time and leisurely take my 
leave from the hotel. I cross Mike in the lobby, which allows us to 
make our good-byes (he's staying for Dave Rolsky's Moose workshop). At around
noon, I pile up in the shuttle with Tommy and a few other fellow YAPCers. 
At the airport, I pick up my tickets, and waltz through security
(Asheville, I must say, has the nicest bunch of security officers
I ever met).

I spend a few minutes with the Californians, who
soon have to board their flight. 
So I'm left to my own device and proceed to rock away 
the few hours before my flight in 
those
nice rocking chairs peppered throughout
the airport.

By then, I'm beginning to worry about my Karma. Such smooth
and pleasant proceedings couldn't be good for the cosmic balance.
And as, eventually, everything has to even out, I'm kind of
dreading the potential backlash when Fate will finally wake up and snap.


I'm eventually joined
by [Robert Blackwell](https://www.socialtext.net/perl5/robert_blackwell), who is sharing
my flight. As it happens, we exchanged a few words earlier at the hotel, 
and so we continue where we left of. He's a darned nice guy and it's all
fun and interesting. This is not helping my karma at all. I peek at
the schedule screen, and see that our flight is slightly delayed. Good.
it's not going to make a major dent in my karmic balance, but it's better
than nothing.

And that's when we are joined by Stevan Little and Eric. Oh my. Karma
is going up like a pinball scor--

The lady at the gate pick the phone/intercom
thingie, clear her throat and announce that our
plane had small mechanical difficulties and was a teensy bit on
fire. Consequently, the flight is cancelled.

-- ah, okay. Nevermind. Fate decided to flush out the buffers, it seems.

Dramatization aside, the situation is more of a minor hindrance than anything
else. First, the plane nicely caught fire *before* anybody got in, which 
is always a big plus. It's still relatively early, and we're stuck in bucolic
Asheville, as opposed to, say, Snake Plissken's New York. So we queue 
to be processed by the routing engine (the aforementioned lady at the gate)
and wait for our turn.

And wait.

And wait.

It's apparent that the throughout of our routing engine is abysmal. Why
aren't they firing up a second instance and use a load balancer between them?
Oh well..

Finally, *finally*, it's our turn. Robert is lucky enough to be redirected
on a later flight that evening. For the Moose master, his mate and me, no such
luck. But we could get flights the day after (yay!), and the airline
is nice enough to give us rooms in a hotel across the street.

The hotel is nice enough. Unfortunately, and even though it was now
non-smoking, it had absorbed enough tar from generations of smokers to
have a ever-present... aroma conjuring images of Patty and Selma to mind.
*brrrrr*

Anyway. Meanwhile, thanks to the wonders of iPhones, Stevan had localised a nice Thai 
place within skipping distance, and offer me to join the party. 
But I didn't feel like, so declined and stayed in my room for the rest of the evening.

Just kidding.  I mean, *come on*. Yummy Thai?
Eaten in company of wonderful chaps? One of them the brain from which
all the cool antlers of the Perl world grew? Who in their right mind would
pass on that?

And, indeed, it would have been a shame to miss it. Amongst other things,
we briefly discussed [Dancer](cpan), but... more details
about that in a future blog entry.

The morning after, I wake up from a weird dream where mst was
inexplicably arguing with my dad, and then went to take a nap with 
a gruff little teddy bear (my psychologist assures me that subconsciouses
aren't required to make up sensed stuff, which would reassure me more if he
wasn't always saying that between sobbing fits). 

Eric had an early flight, but I was able to share the shuttle to the airport
with Stevan. We pass the time with some more chit-chat, and then take off to
the sky.
I'm left to my own device, with a few hours to rock away on those comfy
rocking
chairs peppered all over the airport. Hmmm... Déjà-vu.

So time passes and, uh, did the schedule screen just displayed "cancelled"
beside my flight number?

Yup. Sure did.

By now, I know the drill. Happily, the airline
upgraded their system since the day before, and
this time we have three routing processes. We
are processed much faster, and to my relief there is
a second flight leaving for Charlotte a little later, but 
still early enough for me to get my connection.

Woohoo!

That plane, I'm happy to report, didn't explode, get canceled or dropped in an
unknown cranny of the space-time continuum. Without incident, I made it to
Charlotte, and still without incident, I was to touch down in Ottawa a 
mere few hours later.  I celebrated the last bit of Canada Day by having a
beer at my favorite pub with my love, and a few hours later I was sleeping in my bed. Which
didn't smell anything like Patty, or Selma. Bliss, truly, is home.

## Last Word

Again, much kudos go to the organizers of YAPC::NA 2011. You guys rock.

Big shout out to everybody I met during the conference. You were all
fantastic.

And a huge thank to [Pythian](http://pythian.com) for letting me go in the first place.
I'll make sure the ROI on the expedition will be well worth it. :-)

