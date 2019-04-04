---
title: Plastering 'endorse' buttons all over the (coder)wall
url: coderwall-button
format: markdown
created: 11 Nov 2012
tags:
    - Perl
    - coderwall
---

I'm ashamed to say, I've been slacking off in the blogging department. I
believe, however, that I can plead attenuating circumstances considering that
I'm busy doing terrible things to Dancer 2 and that I just dusted off the elf
bonnet and began to churn out proposals for the [Perl Advent Calendar](http://www.perladvent.org/2012/).

But still, I felt like I should resurface for a few minutes, if only to give a
token sign of life. So here goes:

## Minor Improvements to GitStore

A new version of [GitStore](cpan) has hit CPAN. Nothing very spectacular,
just two little tweaks to provide more access to the underlying Git repository.

The first provides a way to get the listing of all entries (possibly filtered
by a regex) in the store:


    #syntax: perl
    use GitStore;

    my $gs = GitStore->new( '/path/to/the/store' );

    my @foo_thingies = $gs->list( qr/\.foo$/ );

    do_something_with( $gs->get($_) ) for @foo_thingies;

And the second allows to access the `GitStore::Revision` object corresponding
to the current state of an entry.  It was already available via the
`history()` method, but this way is just a wee bit more handy:

    #syntax: perl

    my $rev = gs->get_revision( 'sumfin.foo' );

    # meta-information goodness
    my $last_modified  = $rev->timestamp;
    my $commit_message = $rev->message;

    # and, of course, the entry's content
    my $content = $rev->content;

What's big is more what is looming over the horizon. Thanks to
[SawyerX](https://twitter.com/PerlSawyer/status/265136836408664064),
I've discovered [Git::Raw](cpan), an interface to `libgit2`, and oh boy
is this bad boy *fast*.  When I have time (ah!), I want to have `GitStore` use
`Git::Raw` if it can, and `Git::PurePerl` if it must. But for that to happen, 
`Git::Raw` will need to have access to a few more `libgit2` functions. Which
means the usual: somebody's probably going to end up with a few patches being
left on their doorsteps. 

## Mirror, Mirror on the Coderwall, Who Shave the Most Yaks of Them All?

And now for our main attraction... Not that there is a lot of code to show,
but... I noticed earlier today that [Coderwall](http://coderwall.com) has a
widget that allows peeps to endorse users. "Cute", I thought. As my GitHub
projects usually have a [Dist::Zilla](cpan)-produced Markdown README,
it'd be kinda cool if there was a way to automatically add that widget to the
README, and thus the main GitHub page of the project. Well, [now there
is](https://metacpan.org/release/Dist-Zilla-Plugin-CoderwallEndorse), and its
output can be admired on its own [GitHub page](https://github.com/yanick/Dist-Zilla-Plugin-CoderwallEndorse).

And then I thought... "Wouldn't it even funnier if that same widget could be
seen on MetaCPAN?" Well, it's not there yet, but [the patch has been
submitted](https://github.com/CPAN-API/metacpan-web/pull/702).

So... yeah, I guess what I'm trying to say is: I've kept silent, but not
necessary idle. :-)
