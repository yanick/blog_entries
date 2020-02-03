---
created: 2020-02-02
tags:
    - git-vaudeville
    - git
    - hook
---

# `git integrate` all humans

A few months ago I came up with [git-vaudeville][], a git hook management
system. Quite a basic affair, but it allows
for a few nice tricks; one of them being the creation of custom phase hooks. 

In this blog entry, I'll show how it can work using a made-up git command
living at the core of my workflows: `git integrate`.

## The motivation: merging good, but integrate

When I code, I have a golden rule: the development branch belongs to me,
the main branches belong to the project. 

That means that during 
development I can -- and believe you me, I do -- do all kinds of atrocities. 
I generate tons of commits with unhelpful "wip" messages. I commit, revert,
revert the revert. I break tests. I mix features together. I am, in short, the
monster your managed warned you about.

But it also means that once I did what needed to be done, I feel a
professional duty -- nay, pride -- to erase, delete, remove, and bleach all of
my ignominies. What happens in the kitchen might be a bloody butchery, but
what will be placed on your table *will* be both delicious and
Instagram-worthy.

That transition from hacking floor to world presentable follows a
pretty consistent list of 
sanity checks, and grooming actions. The coded needs to be linted according
to the project's rules. Commits have to be tidied and aggregated. Swearing and
sensitive information has to be filtered out. Etc.

Enter the concept of an *integration merge*, as a merge targeting an "official"
branch for which grooming has to performed in addition of the merging itself. 

Years ago I wrote a Perl script implementing such a `git integrate` commmand
(and blogged about it [here](/entry/git-integrate)). It's a script that served
me well, but with `git-vaudeville`, we can break it in smaller bits.

## 'git integrate' by the way of git-vaudeville

What we want to do is to implement all checks as individual hooks and create a
`git integrate` command that is, at its core, as basic as possible. 

Thanks to `git` picking any `git-*` executable in the path as a cromulent
git subcommand, we can do that by writing this `git-integrate` shell script:

```sh
#!/usr/bin/env fish

set -l branch $argv[1]

set -x GIT_INTEGRATE_ARGS $argv

if test -z $branch
    set branch master
end

git vaudeville run integrate $branch ( git rev-parse HEAD)

set dirty ( git status --porcelain )

if test ! -z $dirty
    echo "oh my, stuff is lying around"
    for line in $dirty
        echo $line
    end
    exit 1
end


git checkout $branch
and git merge --no-ff -

```

The magic line there is `git vaudeville run integrate`, which tells
`git-vaudeville` to run all hooks related to the phase `integrate`. 
`integrate` is not a real 
git phase, but `git-vaudeville` -- blessed be its simple mind -- doesn't 
know that and doesn't care. 

And thus, because we've created a new pseudo-phase we can use to dump all the
tests and actions our hearts desire, the main script is left with a single
hard-check, where we verify that  the branch is
devoid of any littering before the merge. If it is indeed clear, we do a non-fast forward
branch and call it a day.

## A few hooks

So, what kind of hooks can be implemented? For giggles and inspiration,
here's a few I'm using these days.

### atop-target

Whenever I can, I rebase my work branch atop 
the main branch, as it makes for a cleaner history. If I can't,
I still try to merge the main branch in, to deal with 
any conflicts on my own terms.

```sh
#!/usr/bin/env fish

set -l target $argv[1]

git branch --contains $target | grep '^\*'

if test $status -ne 0
    echo "not rebased atop $target"
    exit 1
end

echo "rebased atop $target"
```

### lint

A lot of projects have specific linting rules. If I
detect one, lint the files I've touched, and commit the
cleanup automatically.

```sh
#!/usr/bin/env fish

function do_prettier -a target branch
    echo "prettier detected"

    set files ( git diff --name-status $target... \
            | perl -anE'say $F[1] if $F[0] =~ /[MA]/' )


    prettier --write $files
    or exit 1

    git add $files

    git status | grep 'working tree clean'
    or git commit -m "prettier"

end

if test -f prettier.config.js
    do_prettier $argv
else if test -f package.json -a -n (cat package.json | jq .prettier)
    do_prettier $argv
else
    echo "no linter detected"
end

```

### no-console-log

In JS-land, a good debugging session often involves
a liberal peppering of `console.log`. I don't want them 
to seep in the final product:

```sh
#!/usr/bin/env fish

eval contains -- --no-no-console-log $GIT_INTEGRATE_ARGS;
and exit

if test ! -f package.json
    echo "not a javascript repo, skipping"
    exit
end

set -l target $argv[1]
set -l branch $argv[2]

set output (git diff $target...$branch | grep '^\\+.*console.log' )
if test -n "$output"
    echo "console.log detected"
    for line in $output;
        echo $line
    end
    exit 1
end
```

### no-fixup

Any fixup commit should be squished before a merge.

```sh
#!/usr/bin/env fish

set -l target $argv[1]

set -l fixups ( git log --oneline $target...| grep 'fixup!')

if test -n "$fixups"
    echo got some 'fixup!' commits to squish
    for line in  $fixups; echo $line; end
    exit 1
end
```

### run-tests

Merging code that causes tests to fail? That's embarrassing.

```sh
#!/usr/bin/env fish

if test -f package.json
    npm run test
    exit $status
end

if test -f dist.ini
    dzil test
    exit $status
else if test -d t
    prove -l t test
    exit $status
end

echo "no test framework detected"
```

## Next steps toward an integreater future 

For now I'm mostly satisfied with the system as-is. I might create 
an `examples` directory as part of `git-vaudeville` where I'll dump some of
my most useful hooks. Something else I have a mind of doing is adding
the ability to interactively disabling some hooks for a specific run, for 
those times when you consciously need to break the rules. But in the
meantime... enjoy! 



[git-vaudeville]: https://www.npmjs.com/package/git-vaudeville
