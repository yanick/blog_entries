---
created: 2015-10-15
updated: 2015-10-16
tags:
    - git
---

# Git last

**Edit::** Eric Johnson, in the comments, let me know what I partially reimplemented an
already existing wheel. The shocking details are in a new last section, "The wheel, reinvented".

This is a quick one about two new aliases I have added to my Git menagerie.
It's nothing big, but I think they can be handy.

I don't know if you're like me, but when comes the time
to merge branches in Git, I tend to hop between branches like a crazed rabbit.
More often than  not, the hopping happens between two branches. And so instead
of  doing `git checkout this` and `git checkout that` and `git checkout this`
again, I felt
the need to be able to say `git checkout... just checkout the last branch, okay?`.

Well, that shouldn't be too bad to do, as
Git does retain information about the move from one branch to the
next:

``` bash
$ git reflog 
191d461 HEAD@{0}: checkout: moving from d2p2 to d2p2
191d461 HEAD@{1}: commit: working
a939e7a HEAD@{2}: checkout: moving from master to d2p2
a939e7a HEAD@{3}: commit: v1.7.0
aa31c53 HEAD@{4}: merge dzil: Merge made by the 'recursive' strategy.
2cc2660 HEAD@{5}: checkout: moving from dzil to master
8937ae1 HEAD@{6}: commit: up the D2 version
b76596e HEAD@{7}: commit: manifest
6076d3d HEAD@{8}: commit: mailmap for gwg
2cc2660 HEAD@{9}: checkout: moving from master to dzil
2cc2660 HEAD@{10}: commit (amend): merge branch 'pr/7'
893116b HEAD@{11}: merge pr/7: Merge made by the 'recursive' strategy.
5efd217 HEAD@{12}: checkout: moving from pr/7 to master
9dc7d25 HEAD@{13}: commit: changelog
7694211 HEAD@{14}: commit (amend): simplifications
f108d65 HEAD@{15}: reset: moving to f108d65
```

So it's just a question of munging. And munging is one of the things I do
best.

So I added two aliases, `last` and `colast` to my
[.gitconfig](gh:yanick/environment/blob/master/git/gitconfig#L13):

```
[alias]
    last = "!f(){ \
        git reflog \
        | perl -nE'BEGIN{ $i = shift @ARGV }' \
                -E'say $1 if /moving from (.*?) to/ and ( $i eq \"all\" or ! $i-- )' $1 \
        }; f"

    colast = "!sh -c 'git checkout `git last $1`' -"

```

`git last` prints out the last banch we were on. Or the *n*th one if we
provide a number. Or the whole history if we give it `all`:

``` bash
$ git last all
d2p2
master
dzil
master
pr/7

$ git last
d2p2

$ git last 1
master
```

And since I wanted this to mostly jump back to those previous branches,
`git colast` add that extra, final functionality:

```bash
$ git co master
Switched to branch 'master'
Your branch is up-to-date with 'github/master'.

$ git colast
Switched to branch 'd2p2'
 
$ git colast
Switched to branch 'master'
Your branch is up-to-date with 'github/master'.

$ git colast
Switched to branch 'd2p2'
```

Two notes before I leave:

* It'll be nice to have the times of the branch jumps in the history, but
`git reflog` doesn't (to my knowledge) keep that information. Although we
coudl easily use the commit associated with the reflog line as a lower bound
for that switch time.

* I could push the concept one step further and have my shell populate an 
environment variable `$GIT_LAST` each time the prompt is generated (the shell
`fish` even provides hooks that are perfect for that). But considering that
things would get messy once I switch to a directory under a different
repository... nah, I don't think it's worth it.

## The wheel, reinvented

A few hours after the initial writing of the blog post, Eric Johnson pointed out
in the 
comment section that there's already some 
of that functionality baked in in `git`.  `git checkout @{-N}` will
check out the last nth branch, with a special alias `git checkout -`
for the previous branch. The `@{-N}` notation also work anywhere else where
a commit can be given, like for `git log @{-1}`.

So that pretty much obsolete `git colast` right there. But `git last`
itself might still be useful. Win some, lose some, learn lots of stuff in between. Heh. I can live with that. :-)



