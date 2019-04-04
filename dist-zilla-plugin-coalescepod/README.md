---
url: dist-zilla-plugin-coalescepod
format: markdown
created: 4 Feb 2012
tags:
    - Perl
    - Dist::Zilla
---

# Introducing Dist::Zilla::Plugin::CoalescePod

Yup. Plucking the alpaca's eyebrows again, I'm afraid...

You see, [because of merciless peer
pressure](http://babyl.dyndns.org/techblog/entry/perl-achievements-ii), I've revived
[Perl::Achievements](cpan). I thought that would keep the wolves at bay,
but noooo... Not a hour after the announcement was sent, I got a [new feature
request](https://twitter.com/#!/genehack/status/165252271981080576). I really
should not but... okay, I wanted to do it anyway and if somebody is actually
asking for it, why the heck not?  Plus, it'll give me the opportunity to see
if my [Template::Caribou](http://babyl.dyndns.org/techblog/entry/caribou) is up to snuff.

A few hours later, I have a [bug
report](https://rt.cpan.org/Ticket/Display.html?id=74668) for
[MooseX::App::Cmd](cpan) and (after some touch-ups) released the
first version of [Template::Caribou](cpan) on CPAN.

And that's roughly where things get silly... 

You see, while I like to keep the pod of functions and
methods with their implementation, the big fluffy sections like
*SYNOPSIS* and *DESCRIPTION* lumbering at the top of the module files kinda
get in my way.  Of course, as I'm using [Dist::Zilla](cpan) and
its [Pod::Weaver](cpan) goodness, I could also punt them at the bottom of
the file and let the weaver reorder them at building time.

Or... I could push the idea an inch further, have those sections in their
own pod file, and have them merged back to their corresponding modules at
building time.

Which is exactly what [Dist::Zilla::Plugin::CoalescePod](cpan) does. For
each pod file it finds, it checks if a corresponding module exist. If it does,
The pod is appended at the end of the file verbatim (to be later on munged and
reorganized by `Pod::Weaver`) and the pod file itself removed.

And now that all of this is out of my system, I can return to
[Perl::Achievements](cpan). 

Well, I should probably update 
[Dist::Zilla::PluginBundle::YANICK](cpan) first.

...the Yak shaving. It never stops. It... just... never... stops.  \*sob\*


