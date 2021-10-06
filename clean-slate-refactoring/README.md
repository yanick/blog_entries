---
created: 2021-10-02
summary: A Git strategy to massively refactor a codebase without going insane.
tags:
    - git
---

# Clean slate refactoring

<img src="__ENTRY__/slate.jpg" alt="a slab of slate, clean of course" 
    class="hero" />

Thanks to my tinkering instincts and chronic indecisions, I'm terrible at is
picking a technology and sticking with it.  Which means that I'm quite prone
to utter those dread words: "screw it, I'm going to rewrite it. FROM
SCRATCHES!".

But it's rare that "from scratches" really means "from *scratches* scratches".
I'm likely to want to keep some files as-is. Most will be modified, sure, but
I might still want to at least be inspired by the code I wrote before. 

What to do, then? 

One option is to create a new empty repository beside the
old one, and manually copy (and alter) files from the old to the new. 

Another is to create a new branch, and progressively convert the files within
that branch. 


Both options are... not optimal. With the side-by-side repos, as the
transition goes on keeping track of what already has been done and
what remains to be addresses gets harder and harder.  As for doing 
*in situ* migrations, we end up with the old and the new all intermixed in 
what can easily turn into a huge confusing mess.

But wait, there is a third option! Leveraging some of Git's features, 
we can follow a "clean slate refactoring" procedure that will keep for us a
living laundry list of all that is left to do. Here, let me show you.

## The use case: git-vaudeville

It's better to show than to tell, so let's pick a concrete example:
[git-vaudeville](https://github.com/yanick/git-vaudeville). This package is
currently written in TypeScript. For giggles, let's say I want to change it
back to pure JavaScript. How would I go about it?

## First step: ANNIHILATION!

I'm calling this "clean slate refactoring", so let's
give ourselves a fresh new start. First by creating a 
work branch for our rewrite.

### hackthrough

#### ./step1.bash

Earmarking the beginning of the rewrite branch. It'll
will come in handy later on.

#### ./step2.bash

And now creating the refactoring branch proper.

### /hackthrough


Oh yeah, small note: `git cob` is one of my aliases, here standing for
`checkout -b`.  I debated putting the long form of the commands instead.
Unarguably be more pedagogical, but not as fun. In any case, I'll point out
when I'm using one of those yenzie specials, and all aliases used in this
articles will be listed at the end -- I might be a vain showoff, but I'm not a
monster.

Back to our example. Let's now remove *everything* from the working tree.

### hackthrough

#### ./step3.bash

Remove everything. Spare no one.

#### ./step4.bash

Commit what will become our todo list.

#### ./step5.bash

Welcome to Tabula Rasa!

### /hackthrough


That `wip-clean-slate` commit is going to be our todo list of
files yet to be processed, and our end goal is going to be to turn it into
an empty commit. Until then, at any time we can peek at it to see what
is left to do.

```
$ git show --compact-summary :/wip-clean-slate
commit 98a520965f220e7c0a14b1c42f7573747fa86ace (HEAD -> js-rewrite)
Author: Yanick Champoux <yanick@babyl.ca>
Date:   Wed Sep 29 14:06:53 2021 -0400

    wip-clean-slate

 .gitignore (gone)                       |   4 --
 Changes (gone)                          |  24 -------
 README.md (gone)                        | 138 --------------------------------------
 dist/cli.js (gone)                      |   8 ---
 dist/colors.js (gone)                   |  12 ----
 dist/command.js (gone)                  |  38 -----------
 dist/commands/info.js (gone)            |  39 -----------
 dist/commands/install.js (gone)         |  56 ----------------
 dist/commands/run.js (gone)             |  31 ---------
 dist/commands/run.test.js (gone)        |  16 -----
 dist/hook.js (gone)                     |  67 ------------------
 dist/hook.test.js (gone)                |  12 ----
 dist/index.js (gone)                    |   8 ---
 dist/vaudeville.js (gone)               |  68 -------------------
 jest.config.js (gone)                   |   9 ---
 package.json (gone)                     |  55 ---------------
 src/@types/simple-git/index.d.ts (gone) |   3 -
 src/@types/yurnalist/index.d.ts (gone)  |   4 --
 src/cli.ts (gone)                       |   6 --
 src/colors.ts (gone)                    |  23 -------
 src/command.ts (gone)                   |  40 -----------
 src/commands/info.ts (gone)             |  43 ------------
 src/commands/install.ts (gone)          |  72 --------------------
 src/commands/run.test.ts (gone)         |  16 -----
 src/commands/run.ts (gone)              |  50 --------------
 src/hook.test.ts (gone)                 |   7 --
 src/hook.ts (gone)                      | 127 -----------------------------------
 src/index.ts (gone)                     |   2 -
 src/vaudeville.ts (gone)                |  91 -------------------------
 tsconfig.json (gone)                    |  66 ------------------
 30 files changed, 1135 deletions(-)
```

### Keeping files wholesale

There are some files we want to keep from the old incarnation unchanged.
Here, that'd be `README.md` and `.gitignore`.

There are a few ways to skin that cat. Here's a simple one:

### hackthrough

#### ./step6.bash

Add back the files we want to keep wholesale.

#### ./step7.bash

`fix` is an alias for `commit --fixup`.

### /hackthrough

The big trick I'm using is the `fix` variant of the commit. Because with that,
next time we do an interactive rebase, the fix will be merged with the
original `wip-clean-slate` commit and it'll be just like we never deleted
those files at all.

### hackthrough

#### ./step8.bash

After the commit we have two commits in our rewrite branch.

#### ./step9.bash

We rebase interactively, retcon is my alias for `rebase -i`.

#### ./step10.bash

The fix is now part of the (now altered) original commit.

#### ./step11.bash

And that new clean slate commit actually spared our two files.

### Throwing files in the oubliettes

For files that we want to really discard, we want to extract their
removal from the `wip-clean-slate` commit so that we know it's
not part of the todo list but a deliberate kill.

To do so, we can do a two-step dance where we bring the file back like
in the previous section, and then kill it dead.

### hackthrough

#### ./step12.bash

Bring the file back from the dead.


#### ./step13.bash

Set that as an edit on the clean slate commit.

#### ./14.bash

Now kill it fo' realz.

#### ./15.bash

Rebase to merge the fix with the clean slate commit.

#### ./16.bash

The removal of the file is now in its own commit.

### /hackthrough

A different approach would be to use something like my `git resplit` custom
command (included at the end of the article), which does a rebase where all changes done to specified paths
are extracted from the bigger commits.

### hackthrough

#### ./resplit1.bash

Run the magic command.

#### ./resplit2.bash

At this point the removal of src/@types/* is extracted from wip-clean-slate.

#### ./resplit3.bash

Now I can do an interactive rebase and, say, merge
the split commit with the "don't need types anymore" commit.

#### ./resplit4.bash

We're back to two commits.

#### ./resplit5.bash

And the type deletes are indeed together.

## Everything else in-between

Between the two extremes of keeping as-is and deleting, we have all
the other files we want to keep with modifications. For those we'll
follow the same procedure: pluck them from the `wip-clean-slate`
commit via a fix, then do the edits proper.

### hackthrough

#### ./between1.bash

Pluck from wip-clean-slate.

#### ./between2.bash

Edit the file.

#### ./between3.bash

Commit in the edits. And yeah, `cm` is another of my aliases.

## Alternate picking using the stash

So far what we've done is starting from an empty plate, and incrementally 
picking the files from the `wip-clean-slate`. If you prefer to still 
have all files presents, we can also do that via our old friend the stash.

### hackthrough

#### ./stash1.bash

Bring all the files to the working tree, but don't commit
any of them.

#### ./stash2.bash

All the files are there, and yes, `s` is an alias.

#### ./stash3.bash

First make the 'fix' commit for wip-clean-slate.

#### ./stash4.bash

Do whatever you wanna do.

#### ./stash5.bash

Commit those changes.

#### ./stash6.bash

Before we rebase, we have to stash the untracked files.

#### ./stash7.bash

Now the files are out of wip-clean-slate and their changes 
are all in the last commit.

#### ./stash8.bash

Finally re-apply the stash to continue the good work...


## Addendum: git aliases and commands

### Git aliases

```
cob    = checkout -b
fix    = !f() { git commit --fixup ${1:-HEAD};  }; f
retcon = rebase -i
s      = status
```

### git-resplit

```
#!/usr/bin/env fish

set -l base $argv[1]
set -e argv[1]

git rebase $base --exec "git split $argv"
```

### git-split

```
#!/usr/bin/env fish

if test -z $argv
    echo "must provide at least one path"
    exit 1
end

set -l sha1 ( git rev-parse HEAD )

git reset HEAD^ -- $argv

if test -n ( echo ( git diff --name-only --cached ) )
    git commit --amend --no-edit
end

git add $argv

if test -n ( echo ( git diff --name-only --cached ) )
    echo (git log -1 $sha1 --pretty=%B) "(split $argv)" | git commit -F -
end
```

### git-cm

```
#!/usr/bin/env perl

use 5.24.0;
use strict;
use warnings;

use List::MoreUtils qw/ first_index /;

my $index = first_index { $_ eq '--' } @ARGV;

$index = 0 if $index== -1;

push @ARGV, '--message', join " ", grep { $_ ne '--' } splice @ARGV, $index;

exec 'git', 'commit', @ARGV;
```
