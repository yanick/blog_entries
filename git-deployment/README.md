---
title: Deploying Stuff With Git
url: git-deployment
format: markdown
created: 2011-12-11
tags:
    - Git
    - perl
    - Git::Repository
---

Somebody at `$work` asked me how I use Git to deploy stuff, probably working
under the false hypothesis that wisdom is in any way, shape or form affiliated
with yours truly. The fool...

Yet, it is true that I had my share of tinkering with Git,
and that I might have gleaned from my experience. So I sent him a
couple of links leading to more wisdom-certified sources. They are listed at the end of
this blog entry; if you have more good articles/blog posts that you'd like
to add to the pile, please don't be shy and mention them in the comments.

But
I can't just stop there, really. So, if you allow me, I'll
dust off the good ol' soap-box, hop on it, and share my toughts on
the subject. As usual, don't forget to take an adequatly-sized grain of salt
to go with your popcorn.

## Deploying Stuff With Git?

The first reaction of most people is probably to add that question mark to the
title. Using a VCS for deployment, is it really a good idea? A fair question,
for sure, and one that my experience allows me to answer rather succintingly:

*Hell yeah.*

Okay, maybe I should flesh that out a little more. Git is not only a VCS
(Version Control System), it's a *D*VCS. The 'D' is for distributed, and that
means that one of the core *raison d'être* of Git is to bandy your
code around with a maximum of ease. That sounds like a lot like what
deployment is about, no?

Also, the fact that each clone of a Git repository contains the whole history
of the codebase makes rollbacks and flips to different versions much easier.
Once a deployment machine is synched with the master repository, it is
independent from the mothership. The network can go down, the master
repository can go up in flames, and you'll still be able to
jump back and forth to any version you want.  And thanks to
the [frankly amazing efficiency with which Git compresses its information](http://vcscompare.blogspot.com/2008/06/git-mercurial-bazaar-repository-size.html), it's a
feature with come with a much smaller memory footprint you would imagine.
For example, the [repo of the whole history of the Mozilla project
clocks 450M](http://keithp.com/blogs/Repository_Formats_Matter/). Considering
that the checkout of the latest version is 350M, it means that for an overhead
of not even 150% you get everything single commit that was done for the last
ten years. Unless you are routinely deploying the whole KDE codebase on
venerable Commodore 64 machines, the trade-off between additional memory and
conveniency is so overwhelming it's not even fair.

All of that being said, I should perhaps stick a disclaimer here:

> most
> of the applications I deal with are Perl-based. As with any interpreter
> language, what is deployed is uncompiled, plain text source code. And
> pure text stuff is what Git (and most VCS) excels at.  With compiled
> applications (C, C++, java, etc), the trade-offs are going to be different.
> Do I still think that Git can still be a viable deployment tool in those
> cases? Most probably. But remember: it's not because I'm extolling you the virtues of my hammer
> that we should forget that there is more than nails out there.

Good. Now that this is out,  let's see what hammering tips I can find for you...

## Create a Deployment User

If you are deploying an application, create a user for it. On any Unix-like
platform, creating a user is only a `adduser` away. It makes security
matters so much easier on all fronts: for the ssh key generation, for `sudo`
permissions, etc. It also makes things easier to find -- it's all under
the ~app account. And, as a bonus, you can stuff the '`.bashrc`' of that user
with application-centric commands and settings.

## Have a Branch for Releases

Unless the repo is not used for development at all, consider using a release branch
for the states of the repo that you want to deploy. And even then, having that
release branch is probably a good idea to make things as clear and obvious as
possible.  Because  the last thing anyone want is to have the latest
experiment from a crazed developer seep out on all deployment machine. As one
of those crazed developers, trust
me on that one.

## Decoupling Checkout and Local Repo

By default, Git stashes the repository information in a '`.git`' subdirectory
at the root of the clone. Sometimes, because of the nature of what you're
deploying or just for good ol' OCD's sake, you might want to have the repo and the
checkout at two different places. That's no problem, thanks to the `GIT_DIR`
(aka repo subdir)
and `GIT_WORK_TREE` (aka checkout) environment variables.

For example,
let's assume that we are deploying an application
called [Galuga](https://github.com/yanick/Galuga), that our master repository is on the
machine Enkidu and that our deployment machines are Gilgamesh and Siduri.
Let's further assume that we heeded the previous recommendation, and that on
the deployment machines we have a `galuga` user, with all the proper ssh key
sharing between them and the master user on Enkidu.
So, if want the repo information to be in '`~/repo`' and the checkout to be in
'`~/galuga`', we can add the following lines in the '`.bashrc`' of
our deployment drones:

    #syntax: bash
    # in the .bashrc of galuga@[Siduri,Gilgamesh]
    export GIT_DIR=~/repo
    export GIT_WORK_TREE=~/checkout

And then from Enkidu:


    #syntax: bash
    $ ssh galuga@gilgamesh \
        'git clone ssh://yanick@enkidu/home/yanick/work/Galuga $GIT_DIR'
    Cloning into /home/galuga/repo...

    $ ssh galuga@gilgamesh 'ls ~/repo'
    branches
    config
    description
    HEAD
    ...

    $ ssh galuga@gilgamesh 'ls ~/checkout'
    Changes
    galuga.conf
    lib
    Makefile.PL
    ...

Bonus point, since our user only has one repo to worry about, and that the
information is contained in the `.bashrc`, we don't even have to be in the git
checkout directory to use any of the git commands:

    #syntax: bash
    $ ssh galuga@gilgamesh 'git status'
    # On branch master
    nothing to commit (working directory clean)

## Don't Push Directly to the Local Branches

Of course, we all know what we should never edit deployed code directly.
Any change should be made in a development environment, pushed to the master
repo, and then pushed to the deployment boxes.

We should never edit deployed code directly. But we will. Now, don't give me that outraged look.
We *don't* want to do that. We know that it's generally a bad idea to do that.
But sometimes, when dealing with a honest-to-God emergency, it's the right
thing to do. So it's better to keep a distinction of the branches as they are being
pushed from the master repo, and as they are on the deployment machine, even
if we don't expect them to be ever different (and unless we have a very good
reason for that, they shouldn't).

How to do that? Simple, we push to the remote tracking branch instead of the
local copy. If we use same example as before, we didn't specify any name for
the origin of the clone, so its name is going to be the default *origin*:

    #syntax: bash
    $ ssh galuga@gilgamesh 'git branch -a'
    * releases
      master
      remotes/master
      remotes/releases

Before pushing, we need the master repo to
know about its minions:

    #syntax: bash
    $ alias pgit='perl -MGit::Repository \
        -e"\$git = Git::Repository->new;"'

    $ pgit -E'$git->run( "remote", "add", "minion/$_", \
        "ssh://galuga@$_/home/galuga/repo" ) for @ARGV'\
        gilgamesh siduri

    $  git remote
    minion/gilgamesh
    minion/siduri

The Perlish way of setting the minions is there because I am thinking ahead
when we'll have
hundreds of minions to register. If we only deal with one or two deployment boxes,
then

    #syntax: bash
    $ git remote add minion/gilgamesh ssh://galuga@gilgamesh/home/galuga/repo
    $ git remote add minion/siduri    ssh://galuga@siduri/home/galuga/repo

will do just as well, although it won't look so l33t.

Anyway, now that we know about our minions, pushing the new changes of the
branch 'releases' to them is a matter of doing:

    #syntax: bash
    $ git push minion/gilgamesh releases:remotes/origin/releases

or, if we have hundreds of deployment boxes:

    #syntax: bash
    $ git remote | grep '^minion/' | \
        pgit -n -e'$git->run( \
            "push",  $_, "releases:remotes/origin/releases" \
            )'

## You Want to Push Directly to the Local Branch?

You are sure? Really? Okay. It's your funeral.  Just remember that by default
Git will prevent you to push directly to the branch being checked out:

    #syntax: bash
    $ git push minion/gilgamesh releases
    Total 0 (delta 0), reused 0 (delta 0)
    remote: error: refusing to update checked out branch: refs/heads/releases
    remote: error: By default, updating the current branch in a non-bare repository
    remote: error: is denied, because it will make the index and work tree inconsistent
    remote: error: with what you pushed, and will require 'git reset --hard' to match
    remote: error: the work tree to HEAD.
    remote: error:
    remote: error: You can set 'receive.denyCurrentBranch' configuration variable to
    remote: error: 'ignore' or 'warn' in the remote repository to allow pushing into
    remote: error: its current branch; however, this is not recommended unless you
    remote: error: arranged to update its work tree to match what you pushed in some
    remote: error: other way.
    remote: error:
    remote: error: To squelch this message and still keep the default behaviour, set
    remote: error: 'receive.denyCurrentBranch' configuration variable to 'refuse'.
    To ssh://galuga@enkidu/home/galuga/repo
    ! [remote rejected] releases -> releases (branch is currently checked out)
    error: failed to push some refs to 'ssh://galuga@enkidu/home/galuga/repo'

So if you know what you are doing, you'll need to change the config of the
deployment box to disable the check:

    #syntax: bash
    $ ssh galuga@gilgamesh 'git config receive.denyCurrentBranch ignore'

    $ git push minion/gilgamesh releases
    Total 0 (delta 0), reused 0 (delta 0)
    To ssh://galuga@gilgamesh/home/galuga/repo
    da7f7a3..d7db465  releases -> releases

But, again, *baaaaad* idea.

## Using Local Branch for Local Configuration

There is one case where it makes sense to have local branches that aren't just
copies of the master repo: when there are local configurations involved.

There are many ways to deal with local configurations. They can all be present
in the checkout, and the application can be smart enough to chose the right
one. Or we can have, in the master repo, one branch for each deployment
machine that contains its configuration delta and is constantly rebased off
the main release branch. Or we can push the onus of that local configuration
on the local 'releases' branch, that will have to be rebased off the pushed
'releases' branch. Assuming no merge conflict arise, all we have to do at
deploy time is not just to jump on a commit of the origin's branch, but rebase
off it:

    #syntax: bash
    # on Gilgamesh
    $ cd $GIT_WORK_TREE
    # if we just want v1.23 off origin/releases verbatim:
    $ git reset --hard v1.23
    # but if we want to keep our delta:
    $ git rebase v1.23

## Deployment Method #1: Deployment Machines Pulling Changes

The most obvious way to deploy is to treat the deployment boxes
as just regular git clones, on which we'll just happen to checkout
stuff from the 'releases' branch. For example:

    #syntax: bash
    # on gilgamesh, the deployment box

    # retrieve the latest changes
    $ git fetch origin
    remote: Counting objects: 7, done.
    remote: Compressing objects: 100% (3/3), done.
    remote: Total 4 (delta 2), reused 0 (delta 0)
    Unpacking objects: 100% (4/4), done.
    From ssh://enkidu/home/yanick/work/Galuga
    d7db465..ee30419  releases -> origin/releases
    * [new tag]         v1.23     -> v1.23

    # just curious, what's the changes?
    git diff --name-only v1.23
    Makefile.PL
    MANIFEST
    ...

    # looks good, deploy v1.23
    $ git reset --hard v1.23

That's the best way to go if we don't need to have all the deployment
boxes synchronized. Or if the deployment should be human-supervised (or, God
forbid, tweaked).

## Deployment Method #2: Master Pushing, Minions Reacting

If we have a farm of hundreds of deployment boxes, we might prefer
to issue a single command from our master machine, and let the deployment
boxes scramble and do their magic themselves. To do that, we can play with
the `post-receive` hook.

For example, for the simple case where we want the deployment machine to
always be at the bleeding edge:

    #syntax: bash
    #!/bin/sh

    # no really, that's it
    git reset --hard remotes/origin/releases

The push will emit a warning, but it'll do what we want.

Of course, that's only the beginning. If you have a twisted mind, you could
begin to realise that this provides a crude API to send commands to the
deployment boxes. For example, with this `post-receive`,

    #syntax: bash
    #!/bin/bash

    RESTART=`git branch command/restart`

    if [ -z "$RESTART" ]; then
            ~/checkout/service start
            git branch -D command/restart
    fi

restarting the server on gilgamesh is just as easy as

    #syntax: bash
    $ git push minion/gilgamesh releases:command/restart


Pure evil? Nyaaah... Maybe. But potentially handy too.


## References

* [A Pure Git Deploy Workflow](http://blog.zerosum.org/2010/11/01/pure-git-deploy-workflow.html)

* [Simple Git Deployment](http://ryanflorence.com/simple-git-deployment/)

* [mislav/git-deploy on Github](https://github.com/mislav/git-deploy)

* [apinstein/git-deployment on GitHub](https://github.com/apinstein/git-deployment)
