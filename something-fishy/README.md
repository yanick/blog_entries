---
title: Something Fishy
url: something-fishy
format: markdown
created: 21 Nov 2013
tags:
    - perl
    - fish
    - perldoc
    - App::GitGot
    - Dist::Zilla
---

This one will be terse. I just needed to share the bounty. 

So after tackling that [fish shell completion for
perlbrew](blog:teaching-to-fish), I went on and churned a few more.

## Perldoc

First and foremost, a port of one of my shiniest sparks: the perldoc bash completion
that started [here](blog:local-pod-browsing-using-podpomweb-via-the-cli) and
has been [improved on by Aristotle](gh:ap/perldoc-complete).

<div align="center">
<iframe src="http://showterm.io/012db661682195977fd6a" width="640" height="480"></iframe>
</div>

## Dist::Zilla and Got

And then, just because it's so easy, I also went ahead and did the same
for the sub-commands of both [dzil](cpan:release/Dist-Zilla) and
[got](cpan:release/App-GitGot).



<div align="center">
<iframe src="http://showterm.io/eec2ced1e85e0e1385007" width="640" height="480"></iframe>
</div>

And when I say easy, I mean easy. In both cases, the autocompletion is
auto-munged from the 'help' output in a glorious one-liner. I'm not kidding,
here's the content of `dzil.fish`:

``` bash
eval (dzil help | perl                               \
-ne'print qq{complete -c dzil -a $1 -f -d \"$2\";\n} \
          if /(\w+):\s+(.*?)\s+$/')
```

If you want to join the fun, the syntax of `complete` is really not that
complicated. If we take the same example and expand on the arguments used, we
have:

``` bash
complete -c dzil        # the command to auto-complete
         -a authordeps  # one, or many (whitespace-separated), options
         -f             # can't be followed by a filename 
         -d "do stuff"  # a description         
```

There are more to know than that, like how to deal with subcommands and
conditional suggestions, but that's already a good start.

In all cases, the fish files are in my [environment
repo](yanick/environment/tree/master/fish/completions), and should be PRed
soon enough to the different projects they belong to. While I'm at it, I might
also begin to gather those completions under a 'perl' umbrella within the [Oh
My Fish!](gh:bpinto/oh-my-fish) project.
Oh, and you can expect
a [MooX::Cmd](cpan:release/MooX-Cmd) (or maybe for
[MooseX::App::Cmd](cpan:release/MooseX-App-Cmd)) plugin to auto-generate the fish
autocomplete file pretty soon.

Enjoy!
