---
url: catalystx-info
created: 2014-11-09
tags:
    - Perl
    - Catalyst
---

# Fumbling Toward CatalystX::Info

For once, what I'm about to blabber about is not yet on GitHub nor CPAN. See
it as a promotial sneak preview. Or a merciless tease, your choice.

Recently, I've been dragged back to Catalyst-land. More specifically, I've
been introduced and let loose on some fairly substantial Catalyst apps.
Yayness.

Something that I've always liked of Catalyst is the route tables that it
prints out at start time in debugging mode. Always useful, even moreso
when one does try to learn the full landscape of the application. However I've
always been irked by the fact that this reporting is intrinsically tied to the 
startup process and Catalyst's logging system. What I would like to do is to
extract the information of the application, without needing to have it running, and be able to do any
kind of wacky stuff I can dream of with the information.

So: `CatalystX::Info`.

What I've done so far with that module ain't high sorcery. I'm simply ripping
the table-reporting guts from the core `Catalyst` dispatcher modules, hosing
them clean and repackaging them into a neat object casing.

```perl
    use CatalystX::Info;

    my $info = CatalystX::Info->new( app => 'Gitalist' );

    for my $action ( $info->all_chained_actions ) {
        say "path: ", $action->path, " is made of ", 
            scalar( $action->segments_chain ), "segments";
        )
    }
```

But now that the information is organized and stuff, I can do things. Like, go
through all the chained actions of an application and figure things about
them.

```perl

    # let's see which routes have at least one chained element
    # in Foo::Controller::Bar

    for my $action ( $info->all_chained_actions ) {
        my @pieces = grep { $_->class eq 'Foo::Controller::Bar' } $action->segments_chain
            or next;

        say $action->path, ": ", join " ", map { 
            $_->pathpart . '()' .  $_->private_name . ')' 
        } @pieces;
    }
```

With that new wealth of information, we can now go just as wild with reports.
For example, how about an interactive visualization of the uri tree? A little massaging,
plus a mini-Dancer app using [vis](http://visjs.org), and boom, here's what
happens if I look at the chained action of [Gitalist](cpan:release/Gitalit):

<div align="center">
<img width="600" src="__ENTRY_DIR__/catx1.png" alt="uri tree of Gitalist" />
</div>

Granted, it's still a bit on the ugly side, but once I tidy up the graph, and
color-code the segments by the controller in which they live, and tie
the whole thing to the POD of said controller, and add a pretty little 
input box to specify a uri to be highlighted in the whole graph? Once
this is done, my friends, that's going to be one sweet Catalyst developing
tool... 

(to be continued)
