---
url: perl-achievements-ii
format: Markdown
created: 2012-02-02
tags:
    - Perl
    - Perl::Achievements
    - Moose
    - MooseX::App::Cmd
    - MooseX::Role::Loggable
    - Path::Class
    - Method::Signatures
    - DateTime::Functions
    - Module::Pluggable
    - Data::Printer
---

# perl-achievements, the return

So there I was, leisurely perusing my twitter feed... Oh, [an entry by
brian d foy](https://twitter.com/#!/briandfoy_perl/status/162974986565459968)? 
Should be interesting. So I [clickety clicked](http://blogs.perl.org/users/brian_d_foy/2012/01/yapc-achievements.html), and let my eyes wander and
almost immediatly fall on

> Yanick already has perl achievements (although it's not on CPAN, wtf Yanick? :) 

As I strongly believe that the measure of a man is taken from
whom he bestirs wtfs from, my first reaction was, and I quote: **WOOHOO**!

My second reaction was to comment on the blog entry, pointing on my own blog
entry [narrating the genesis of the
thing](http://babyl.dyndns.org/techblog/entry/perl-achievements), and
explaining that the absence of the module on CPAN was only to preserve the
latter of the alphaness, lack of documentation and general hackery of the
former.

Was this comment met with understanding and compassion? Ah! I wish! No, it was
met with a dire threat:

> [Yeah, Yanick, you don't get the CPAN achievement if you don't upload
> perl-achievement.](https://twitter.com/#!/briandfoy_perl/status/163099690429198337)

*Eeeeeee!*  The monster. So I had no choice, no choice whatsoever. And thus,
[Perl::Achievements](cpan) is now on CPAN.  The goal of the app (scan
your Perl scripts and unlock achievements in function of what is found
therein) is the same as presented in the original blog entry. I've, however, fleshed out a little bit
more the documentation, tidied up the code a wee bit (well, it's still a mess, but it's
using a lot of cool stuff, so it's a *shiny* mess), and changed the innards
just a tad.

## Wanna use it?

That's easy. With `Perl::Achievements` comes the script 'perlachievements`. To
prepare the playground, do

```bash
$ perlachievements init
```

Which is going to create the directory `~/.perl-achievements`, where the
persistent data used by the app is kept.  Once this is done, scanning a script
or module is only a question of doing

```bash
$ perlachievements scan foo.pl Module.pm ...
```


If your code unlock an achievement, it'll be proudly be displayed on the
console.  A subsequent release will allow you to generate a web page to 
publish your badges of honor, but that's for the future.

Good thing to point out: unlike the previous version, this iteration of
`perlachievements` keep an history of already-seen files (as a sha-1 digest of
the file's content kept in `~/.perl-achievements/scanned`), so you can safely
scan the same file over and over again without skewing your achievements (no,
no, you're welcome).

## Wanna create achievements?

Of course, such a system is boring and useless if it's not filled
to the gills with achievements as various as they are amusing. In that regard,
I've made sure that creating a new achievement would be as easy as possible.
In this case, the strict minimum one has to do to is to create a module under
the `Perl::Achievements::Achievements::` namespace, and implement a `scan()`
method that calls 'unlock()' if the achievement should be awarded. And that's
pretty much it. For example, a `WeekendWarrior` achievement could be
implemented as


```perl
package Perl::Achievements::Achievement::WeekendWarrior;

use Moose;

with 'Perl::Achievements::Achievement';

sub scan {
    my $self = shift;

    my $wday = (localtime)[6];

    return unless $wday == 0 or $wday == 6;

    $self->unlock("Was at the computer during the week-ends");
}

1;
```



There's also  the possibility to have levels, and a mechanism to 
maintain states across runs -- see
<cpan type="module">Perl::Achievements::Achievement</cpan> for a little bit more details.
And, of course, there are mad plans for the future, like getting the description slurped
directly from the module's POD. But even in its current proto-state, it's
surprisingly usable.

Incidentally, I recommend having a peek at the code. It's not very nicely
structured yet (I refactored the whole thing on a mad Sunday frenzy in a
semi-sleep deprived haze, and it shows), but it's using a lot of the latest and coolest
tools: [Moose](cpan), [MooseX::Role::Loggable](cpan),
[MooseX::App::Cmd](cpan),
[Path::Class](cpan),
[Method::Signatures](cpan),
[DateTime::Functions](cpan),
[Module::Pluggable](cpan),
[Data::Printer](cpan), and more (yup, I'm the kind of kid who spill out
his whole toybox at playtime). 

