---
created: 2010-06-06
updated: 2010-07-07
tags:
    - Perl
    - environment
    - tests
    - GitHub
---

# Wherever I May Roam

```perl
    Roamer, wanderer
    Nomad, vagabond
    Call me what you will
    
    $ENV{LC_ALL} = "anywhere";
    my $time = localtime;
    say {$anywhere} my $mind;
    local *anywhere = sub { ... };

    Anywhere I roam
    Where I 'git ghclone environment' is $HOME

        # 'grep may_roam($_) => @everywhere', 
        #                with apologies to Metallica
```

Laziness and a severe addiction to yak shaving conspire to constantly make me
tweak configurations and hack scripts to make my everyday 
editing / shell / development experience as holistic as possible.
Unfortunately the same laziness, combined with my constant hopping between
home and $work computers, severely gets in the way of effectively using
those optimizations. Indeed, although I have those nifty toys installed here and
there, because they are not uniformly installed everywhere I 
constantly find myself using the machines' functional lowest common
denominator.

To fix that, I've began to [dump all my environment's custom configurations,
plugins, tweaks and hacks on Github](http://github.com/yanick/environment). That way, I can
import my whole baseline toolbox on any given box with a simple

    git clone git://github.com/yanick/environment.git

As an added bonus, it also provides me with a public platform to show off all 
my little tricks to the world -- and a way to potentially let other peeps
fork it and customize it to fit their own needs.

However, importing the environment is only half the battle; it also has to be
properly installed. On one hand, the installation shouldn't be manual, as
laziness would slip in again and ensure that it would never happen. On the
other, I'm too wary of unintentional clobbering to leave everything to an
installation script.  So I decided to take the middle road and 
have a set of passive Perl tests verifying if the various components are
applied to the environment. For every tweak that I make, I also write a short
test that checks that it is installed at the proper place. 
Thanks the goodness of Perl's test harness, a quick '`prove t`' is all 
that is needed to let me know if the current environment is in sync with the baseline:

    [yanick@enkidu environment (master)]$ prove t
    t/general.t ... 1/? 
    #   Failed test 'cp bash/mine.bash ~/.bash/mine.bash'
    #   at t/general.t line 15.
    # +---+---------------------------------------------+---+-----------------------------------------+
    # |   |Got                                          |   |Expected                                 |
    # | Ln|                                             | Ln|                                         |
    # +---+---------------------------------------------+---+-----------------------------------------+
    # | 16|source ~/.bash/git-completion.bash           | 16|source ~/.bash/git-completion.bash       |
    # | 17|PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '      | 17|PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '  |
    # | 18|                                             | 18|                                         |
    # * 19|export PATH="$PATH:~/work/git-achievements"  *   |                                         |
    # * 20|alias git=git-achievements                   *   |                                         |
    # | 21|                                             | 19|                                         |
    # * 22|\n                                           *   |                                         |
    # | 23|###########################                  | 20|###########################              |
    # | 24|# Misc                                       | 21|# Misc                                   |
    # | 25|###########################                  | 22|###########################              |
    # +---+---------------------------------------------+---+-----------------------------------------+
    # | 42|                                             | 39|                                         |
    # | 43|complete -C perldoc_complete perldoc         | 40|complete -C perldoc_complete perldoc     |
    # | 44|complete -C perldoc_complete pod             | 41|complete -C perldoc_complete pod         |
    # |   |                                             * 42|\n                                       *
    # |   |                                             * 43|\n                                       *
    # |   |                                             * 44|# aliases                                *
    # |   |                                             * 45|source ~/.bash/aliases                   *
    # +---+---------------------------------------------+---+-----------------------------------------+
    [ etc... ]


It's not a perfect system, and there's still a lot of polishing that can be
done, but I've been using it for a few weeks and it has already been quite
useful.

