---
url: new-and-improved-flood
created: 2012-06-04
tags:
    - Perl
---

# New and Improved: Here Comes the Flood

<div style="float: right; padding: 5px;">
<img src="__ENTRY_DIR__/val_approuve.png" alt="New and Improved!" width="300"/>
</div>

In the last few weeks, I launched quite a few small releases to CPAN. Taken
separately, they are hardly worth a full blog entry, but taken together,
they'll make for a lovely *N&I* entry. So if you have been wondering what I've
been up recently, here goes:

## Git::CPAN::Patch

[Git::CPAN::Patch](cpan) has one new command, `git cpan-clone`, provided by
[Mike Doherty][mike], which mimic the behavior of `git clone`, but with
cpan-added value.

Also, I dove back in the guts of `Git::CPAN::Import` and altered them so that
the fetching of the cpan tarball uses 
[MetaCPAN::API](cpan) and [LWP::UserAgent](cpan)
instead of [CPANPLUS](cpan).  That change gaves the typical use-case a
wee bit of a performance boost. How wee is that bit? Well:

    #syntax: bash
    # with CPANPlus

    $ time git cpan-init Git::CPAN::Patch
    [MSG] No '/usr/local/soft/cpanplus/custom-sources' dir, skipping custom
    sources
    [MSG] No '/usr/local/soft/cpanplus/custom-sources' dir, skipping custom
    sources
    [MSG] No '/usr/local/soft/cpanplus/custom-sources' dir, skipping custom
    sources
    importing Git::CPAN::Patch
    downloading Git-CPAN-Patch-0.8.0.tar.gz
    extracting distribution
    created tag 'v0.8.0' (70cb4765ec367083b88d84a246053f0f4d9c4776)
    Already on 'master' at
    /usr/local/soft/perlbrew//perls/perl-5.14.2/lib/site_perl/5.14.2/Git/Repository.pm
    line 195
    Branch master set up to track local ref refs/remotes/cpan/master.

    real    0m59.742s
    user    0m28.530s
    sys     0m1.230s


    # with MetaCPAN

    $ time git cpan-init Git::CPAN::Patch
    importing Git-CPAN-Patch (Git::CPAN::Patch)
    downloading Git-CPAN-Patch
    extracting distribution
    created tag '0.8.0' (5052f9cc1014fa042843155086943b92c4e4b43b)
    Already on 'master' at
    /usr/local/soft/perlbrew//perls/perl-5.14.2/lib/site_perl/5.14.2/Git/Repository.pm
    line 195
    Branch master set up to track local ref refs/remotes/cpan/master.

    real    0m2.755s
    user    0m0.570s
    sys     0m0.190s

A mere factor of 20 times faster. Boo-friggin'-yah.

[mike]: https://metacpan.org/author/DOHERTY

## Email::Simple::Markdown

The initial release of [Email::Simple::Markdown](cpan) satisfied my itch,
but not the one, as it turned out, of my overlords. They wanted the html
version of emails to still retain some pizzazz. Fair enough. 

So I added the
ability to provide a stylesheet for the html part of the email (as a string
or a hashref, just for giggles), as well as 
a pre-markup filter to manipulate the pristine text version in something
potentially more glamorous.  And while I was at it, I also made possible for
the user to chose between [Text::Markdown](cpan) and
[Text::MultiMarkdown](cpan) for the markdown rendering engine.

    #syntax: perl
    my $email = Email::Simple::Markdown->create(
        markdown_engine => 'Text::Markdown',
        header => [ ... ],
        body => $text_with_markdown,
        css => {
            h1 => { color => 'red' },
        },
        pre_markdown_filter => sub {
            # paste a pre-defined html banner at the top
            $_ = $html_banner . $_;
        },
    );

## CPAN::Changes

An upcoming version of [CPAN::Changes](cpan) should contain a little
patch of mine introducing `tidy_changelog`, which at its core is 
just a very simple wrapper around `CPAN::Changes` to 
parse and print out a changelog from the command-line. 

Of course, I can't
let good enough alone, so the script can also do a little more. Like figure out
what file in the current directory is the changelog if you don't specify it.
Or print the headers off the changelog. Potentially in reverse, so that you
can do things like figure out the last few dates of your releases:

    #syntax: bash
    $ tidy_changelog --headers  --reverse | tail
    changelog not provided, guessing 'Changes'

    0.15 2011-04-11

    0.16 2011-04-12

    0.17 2011-04-21

    0.18 2011-10-18

    0.19 2012-04-30

## Dist::Zilla::Plugin::ChangeStats::Git

I like stats. And one morning I figured out that it would be nifty if the
changelog of a distribution would also contain a churn indicator for
each release. A few hours later, the last of the breakfast coffee was consumed
as [Dist::Zilla::Plugin::ChangeStats::Git](cpan) was born, which is now
appending the coveted numbers to my changes:

    #syntax: plain
    0.8.0 2012-05-22
    [ENHANCEMENTS]
    - Added new command 'cpan-clone', which operates like git-clone [Mike
    Doherty]

    [STATISTICS]
    - code churn: 1 files changed, 4 insertions(+), 86 deletions(-)

## GitStore

The release is pending [Fayland](http://search.cpan.org/~fayland/)'s approval,
but [GitStore](cpan) should soon be able to return the full history
of a stored object, in addition to returning the latest version. 

    #syntax: perl
    use GitStore;
    my $store = GitStore->new( '/path/to/git/repo' );

    # the good ol' way
    my $object = $store->get('/some/object');

    # new, and improved!
    my @history = $store->history('/some/object');

    say "created at " . $history[0]->timestamp;


While this
might look like a random act of patching, I'm actually paving the way for
the rebirth of Galuga which, if you remember, is using git as its 
article repository. So, yeah, there is a method to my madness. I swear.

## Perl::Achievements

Here, I'm just riding the patch provided by Daniel Bruder, who added a
[Schwartzian Transform][schwartz] achievement to
[Perl::Achievements](cpan).

[schwartz]: http://en.wikipedia.org/wiki/Schwartzian_transform


## Dist::Zilla::PluginBundle::YANICK and Task::BeLike::YANICK

Well, okay, so both [Dist::Zilla::PluginBundle::YANICK](cpan)
and [Task::BeLike::YANICK](cpan) are more for personal use. But they can
always be used by the curious to get an insight of the heap of tools that I 
typically rely on.


