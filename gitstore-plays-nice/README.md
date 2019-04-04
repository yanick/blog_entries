---
url: gitstore-plays-nice
format: markdown
created: 2012-06-24
tags:
    - Perl
    - GitStore
---

# New and Improved: GitStore Now Plays Nice With Others

This is going to be a short one, but I think the changes to
[GitStore](cpan) are cool enough to deserve a little blog-squeal.

So, yeah, beginning to play with `GitStore` for *Project Behemorshmallow*, 
I realized that the module had a pretty serious monkeywrench to throw in my 
delicate machinery. It turns out that it was playing fast and loose with
file definitions within the git repository. Instead of having, say, 
a file named *foo* in a directory *bar*, it was storing 
the file named *bar/foo* in the root directory. No problem if you just
use `GitStore` to get at your data, more of a *uhoh*, however, if you are also
manually editing that repository.

At the same time, I also realized that, upon creating the store, all
its stored objects were deserialized and kept on the ready in the store
object. Not a problem for small repositories, but obviously that wouldn't
scale very well.

Sooo... I went to town on `GitStore` yesterday and today, in-between an
*Alien* marathon, a wedding anniversary and a soccer match, and a new version
of the distribution is now on its way to CPAN, solving all those persky
problems.

One point that should be mentioned is that the code churn of the new
release touches close to 50% of the lines of  main module. And yet, I'm
not too overly worried. Why? Because the distribution has an awesome
testsuite that covers 86% of the codebase (100% of the functions are
at least visited), covering all the basic scenarios.  And not only all those
tests fill me with cool, smooth confidence; but they also greatly simplified the
refactoring process.  Instead of having to think of all the repercussions 
some core changes would bring (well, maybe not totally instead, but rather in
addition to), I had the luxury to make those changes, run the tests, see which
corners of the codebase went boom, bring my attention to them, fix them, and
repeat the process all over again -- basically, it cut for me the larger
problem into smaller, easier to deal with, ones. 

I guess what I'm trying to say here, is: automated testing? It's the bee's
knees.

