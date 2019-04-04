---
url: new-and-improved-git-cpan-patch-0.7.0
format: markdown
created: 2011-11-12
tags:
    - Perl
    - New and Improved
    - Git::CPAN::Patch
---

# N&amp;I: Git::CPAN::Patch now detect repositories

<div style="float: right; padding: 5px;">
<img src="__ENTRY_DIR__/val_approuve.png" alt="New and Improved!" width="150"/>
</div>

[Git::CPAN::Patch](cpan) could already seed a local  repository
with the latest distribution of a module, or its whole BackPAN
history, or its GitPAN mirror.  But with version 0.7.0, it can now
go straight for the meat and clone the distribution's officil git repository,
provided that it's specified in its *META.json* or *META.yml*.
Please allow me to demonstrate:

<div style="clear: both"> </div>


    #syntax: bash
    $ mkdir local && cd local

    $ git cpan-init --vcs Git::CPAN::Patch
    repository found: git://github.com/yanick/git-cpan-patch.git
    Branch master set up to track remote branch master from cpan.

    $ ls
    bin       Changes        contrib   dist.ini       distrelease.yml  
    lib       Makefile.PL    MANIFEST  MANIFEST.SKIP  README   
    t         xt

To help figure out if a distribution has a repository or not, one can use the 
new helper command `git cpan-sources`:  

    #syntax: bash
    $ git cpan-sources Git::CPAN::Patch
    Repository
            type: git
            url: git://github.com/yanick/git-cpan-patch.git
            web: http://github.com/yanick/git-cpan-patch/tree


    CPAN
            latest release: 0.6.1 (2011-06-05)
            url: http://cpan.cpantesters.org/authors/id/Y/YA/YANICK/Git-CPAN-Patch-0.6.1.tar.gz

