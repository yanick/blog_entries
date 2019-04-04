---
title: Teaching A Man To Fish
url: teaching-to-fish
format: markdown
created: 2013-11-07
tags:
    - Perl
    - tmux
    - fish
    - perlbrew
---

I like to think that I'm somewhat gifted at finding out, or coming with li'll useful tricks
that improve a hacker's workflow and help to optimize the pain-to-awesomess
ratio of our daily tasks.

I am, however, thoroughly rotten at leveraging them once they are done. Mind
you it's not like I'm 
the first one to suffer from this disorder -- shoemakers, among others, are
known to be especially prone to the syndrome for centuries.  For me, it's just
that solving a problem is infinitely more engrossing than getting rid of that
problem. But that's terribly misplaced laziness...

And so, for the better part of this year I've tried to slow down and focus on
getting my working environment just right, from the metal up. After years of
getting by with Vim, I've bought the very good [Practical
Vim](http://pragprog.com/book/dnvim/practical-vim) and am slowly working my
way to unleashing its full potential. I also picked [the
tmux book](http://pragprog.com/book/bhtmux/tmux) from the same editor, and
began to use in earnest this rather
nifty terminal multiplexer.

Now, sitting in-between the editor and the terminal is the shell itself. 
I've been using bash for years, but since I am on an improvement spree, I
thought surely there is something better out there. And, surprise, surprise,
there is. Or there are, to be exact: two main
contenders quickly stood out, [zsh](http://www.zsh.org) and 
[fish](http://fishshell.com/). `Zsh` is POSIX-compliant and would thus offer a
relatively painless migration from bash, but I took a look at its
[autocompletion
system](http://zsh.sourceforge.net/Doc/Release/Completion-System.html) and...
let's just say I won't be able to scrape off all those brain cells off my
ceiling. `Fish`, by opposition, is offering a friendlier system, but just
slightly different than everything else. But you know me, I never could 
resist a black horse. So I decided to give this little fishie a try.

Unfortunately, this non-POSIXity quickly bit me in the rear. Perlbrew? Its
latest versions are using a bash wrapper to do its magic without opening
sub-shell upon sub-shell.  A wiser man would have taken that as a sign to go
the `zsh` way. But me? [Challenge
accepted](http://questhub.io/realm/perl/quest/524da2727feb4a3965000052).

Aaaaanyhoo. All that to say that [the pull
request](https://github.com/gugod/App-perlbrew/pull/365) has been sent
earlier in the evening. And if you are eager to try it, or if the PR isn't 
accepted (which is quite possible, `fish` is a rather marginal shell, after
all), you can also grab the file from my [environment
repo](https://github.com/yanick/environment/blob/master/fish/perlbrew.fish)
and simply source it from your `config.fish` to have a working `perlbrew`,
complete with some autocomplete goodness.


<div align="center">
<iframe src="http://showterm.io/09452bb20700162bbc0be" width="640" height="480"></iframe>
</div>


Enjoy!


