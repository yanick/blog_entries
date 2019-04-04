---
url: dist-zilla-github
format: markdown
created: 2011-01-23
tags:
    - Perl
    - Dist-Zilla
    - GitHub
---

# Dist::Zilla, GitHub and me

[Dist::Zilla](cpan) is a little bit of a two-edged blade. Whereas
it enormously simplify things for the module author, it can also 
create quite the
speed bump for the casual contributor. Not only the content of the 
repository can diverge strongly from the distribution ("dude,
where's the `Build.PL`? And what the heck happened to the POD?"), but 
to transmute that repository code into its distribution-ready incarnation,
one has no choice to do the `zilla` dance. That is, if one can. In 
my experience it's not unusual to stumble on distribution with a `dist.ini` 
that has plugins that are either onerous to get working on my machine or,
worse, are 
not compatible with their latest versions on CPAN. Indeed, I can remember a
few cases were it took more time to get `dzil build` to work than it took
to write the code patch itself.

In an effort to remove that potential hurdle from my own distributions, 
I've developed a certain pattern that, so far, 
seems to do the trick.  In my `dist.ini`,
I leverage the wonderful [Dist::Zilla::Plugin::Git](cpan) and have:

<pre code="plain">
[Git::Check]
[Git::Commit]

[Git::CommitBuild]
    release_branch = releases
[Git::Tag]
    tag_format = v%v
    branch     = releases

[Git::Push]
    push_to = github
</pre>

The magic is in `Git::CommitBuild`. By itself, `Git::CommitBuild` 
commits the result of a `dzil build` on a branch called <code>build/<i>original
branch</i></code>. 
Those are throwaway branches that I typically never push to my public repository, but that
are very useful to have a quick peek at what the `Dist::Zilla`-generated code will look
like.  

However, it's the optional `release_branch` parameter that interest us
here. When defined, the plugin also commits the build content to the given
branch on a `dzil release`. In other words, it provides us with a branch 
containing the exact code that goes out on CPAN.  It's a tidy branch too,
with one commit per release, just like what [GitPAN](http://github.com/gitpan) 
or `git-backpan-import` from [Git::CPAN::Patch](cpan) would give you.
Except that it's even a bit better as it also keeps the relationship with the
development branch it comes from. For example, here is what
[Catalyst::Plugin::MemoryUsage](cpan)'s repo looks like:

<div align="center">
<img src="__ENTRY_DIR__/branches.png" alt="Catalyst::Plugin::MemoryUsage's repository" />
</div>

So, basically, the repository ends up having two main branches, `master`, on
which the development is done, and `releases`, that automatically keeps track
of the "real" released code.

GitHub can even sweeten the situation a little bit more. 
In the administration page of a
project, it's possible to switch the default branch from `master` to
`releases`.
That way, the casual downloaders/patchers/curious souls 
initially see a version of the code that they can relate with what's on CPAN. 
And if they are brave enough to dive in its `Dist::Zilla` counterpart, it's 
also there for them.

And there is a last, very nice bonus feature of that way of doing things. We
can auto-populate the `README.mkd` of the project by using 
[Dist::Zilla::Plugin::ReadmeMarkdownFromPod](cpan) and adding
the following to `dist.ini`:

<pre code="plain">
[ReadmeMarkdownFromPod]
</pre>

For an example of the resulting generated `README.mkd`, you have have a gander
at my [Task-BeLike-YANICK](https://github.com/yanick/Task-BeLike-YANICK)
GitHub page.

