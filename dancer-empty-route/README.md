---
title: Tricking Dancer With a Kinda-Empty Route 
url: dancer-empty-route
format: markdown
created: 27 Apr 2014
tags:
    - Perl
    - Dancer
---

On the Dancer IRC channel, somebody was asking how to set
the route matching a prefix exactly. The naive approach would be to do

``` perl

prefix '/foo';

get '' => sub {
    return "matches /foo";
};

```

but, alas, it doesn't work. Why? Because Dancer doesn't accept
empty routes, so `''` is not acceptable. Now, that's a behavior that could
be seen as buggy and should get fixed shortly (a
[ticket](https://github.com/PerlDancer/Dancer/issues/1020) is open for it).
But for the moment, let's assume we're stuck with it. So, what can one do?
Well, at least two options are open to us.

The first is simply to declare the root route outside of the prefix scope:

``` perl

get '/foo' => sub {
    return "matches /foo";
};


prefix '/foo';

# all other routes go here

```

It works, but... meh. It also breaks the prefix encapsulation. Which is
nothing terrible, but, really, meh.

The second option is sneakier. It consists in remembering that Dancer routes
can also be defined as regular expressions:

``` perl

prefix '/foo';

get qr/$/ => sub {
    return "matches /foo";
};

# all other routes go here

```

And, sure enough, magic happens and it works. If we run the application with debugging logging,
we can also see the resulting route regular expression that Dancer made of it:

```
[12951]  core @0.000423> [hit #1]Trying to match 'GET /foo' against /(?^:^(?^:/foo(?^:$))$)/ (generated from '(?^:$)')
```

