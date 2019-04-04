---
created: 2018-04-05
updated: 2018-04-07
tags:
    - perl
    - signatures
    - list-lazy
---

# Attribut'ting heads

**Update**: a voice arose in the comment section to point out a way to
do my final one-two sub manipulation without having to declare two
separate functions. Scroll at the end of the blog entry to behold that
trick yourself!

A quick one, but it might come in handy as perl 5.28 is right around the
corner.

So, in perl 5.27.8 backward-compatibility disaster stroke! The parsing
of the experimental signatures and of sub attributes was modified, and
as a direct consequence the order in which they must be declared was
reversed. Fortunately, only someone stark raving mad would dish out both
features on their subs.

Unfortunately, stark raving mad
[represents](https://github.com/yanick/List-Lazy/issues/3).

Basically, the function that worked before 5.27,

```perl
sub lazy_list ($generator,$state=undef) :prototype(&@) {
    return List::Lazy->new(
        generator => $generator,
        state     => $state,
    );
}
```

has to be

```perl
sub lazy_list :prototype(&@) ($generator,$state=undef) {
    return List::Lazy->new(
        generator => $generator,
        state     => $state,
    );
}
```

to work in 5.27 and later. No compromise possible. One wants black, the other
requires white. At first glance, it seems I've doomed myself into choosing
between supporting perl up to 5.26, or only 5.28 and beyond.

But only at first glance. Now if you would excuse me and hold my beer...

## Like a savage

The first and primal solution that the lizard brain comes with first is to
craft code on-demand and `eval` it right on the spot.

```perl
# warp in begin so that the prototype is already visible in the module
BEGIN {

    my @proto = ( '($generator,$state=undef)', ':prototype(&@)' );

    @proto = reverse @proto if $] >= 5.027008;

    eval &lt;&lt;"END";
        sub lazy_list @proto {
            return List::Lazy->new(
                generator => \$generator,
                state     => \$state,
            );
        }
END
}
```

It works. But yeeeeeeah, I feel dirty too. `eval`ing code should only be the last resort.
Surely there is a better way.

## Make them play in their own corner

Something slightly less icky is to use the `if` module (ah! I bet you also
forgot it existed) and redirect the different perls to the implementation that
will please them.

```perl

# in Lazy/List.pm

if $] <  5.027008, 'Lazy::List::Implv26';
if $] >= 5.027008, 'Lazy::List::Implv28';

# in Lazy/List/Implv26.pm

package  # we don't want CPAN to see our shame
    Lazy::List::Implv26;

use parent 'Exporter';

our @EXPORT_OK = qw/ lazy_list /;

sub lazy_list ($generator,$state=undef) :prototype(&@) {
    return List::Lazy->new(
        generator => $generator,
        state     => $state,
    );
}

1;
```

A little bit of code repetition, but at least we're not `eval`ing like brutes.

## Just side-step the issue altogether

Then, finally, I realized that I was like the monkey with its fist struck in
the jar. Or Neo staring blindly at the spoon. The issue is with the order
of the declarations. But if a function only has one such declaration... Then
that declaration doesn't have an order. It simply *is*.

In other words, let's switch the conflict-ridden

```perl
sub lazy_list ($generator,$state=undef) :prototype(&@) {
    return List::Lazy->new(
        generator => $generator,
        state     => $state,
    );
}
```

for

```perl
sub _lazy_list ($generator,$state=undef) {
    return List::Lazy->new(
        generator => $generator,
        state     => $state,
    );
}

sub lazy_list :prototype(&@) { goto &_lazy_list }
```

There. Each sub has either a prototype or a signature, so the
perls have no reason to argue about it, and the `goto` even
mask our shenanigans from the user.  No `eval`, no new perl-specific
module. Just one short line for each subroutine. I can live with that.

## The one-two punch without the two subs

[Graham](https://metacpan.org/author/HAARG) pointed out in the [comment section](http://techblog.babyl.ca/entry/527-attributes#comment-3841961899)
that the prototype can be slatered atop the signature without the definition of an inner function via
the use of [Sub::Util](cpan):

```perl
use Sub::Util 1.40;
sub lazy_list ($generator,$state=undef) {
    List::Lazy->new( generator => $generator, state => $state );
}
BEGIN { Sub::Util::set_prototype('&@', \&lazy_list) }
```

Enjoy!
