---
url: chained-dancer
created: 2011-03-29
tags:
    - Perl
    - Dancer
    - Catalyst
---

# Chained Actions with Dancer

Sometimes, I can be slow on the uptake.

A few days ago, had you asked me one big plus of [Catalyst][1] over
[Dancer][2], 
I would have said "chained actions". Chained actions allow to split the logic
underlaying an uri into smaller components associated with its segments. 
A very neat, *DRY*-friendly ways of doing things. 

[1]: http://www.catalystframework.org
[2]: http://perldancer.org

For example, say that I have
a course subscription web service with the uris
'/user/*name*/courses',
'/user/*name*/course/*course_id*/subscribe' and
'/user/*name*/course/*course_id*/is_subscribed'. With Catalyst,
its controller's actions could look like:

<SnippetFile src="part1.perl" />

But then, I discovered Dancer's 'pass' directive. And I saw the
light.  With Dancer, the chained behavior described above could be done 
with:

<SnippetFile src="part2.perl" />

Granted, it's not as clean as it could be; while writing this example
I discovered that '`prefix`' doesn't play very well with regex-based
routes (darn!), and we're missing a megasplat character to be able to do

```perl
get '/user/**' => sub {
        # for '/user/bob/course/bar' 
        # @splatters = qw/ bob course bar /
    my @splatters = splat;  
};
```

but that isn't anything that a patch or two won't solve. The point is that
not only we can have chained actions, but we are not limited to linear chains.
Our action endpoint can have as many overlapping intermediary routes as we want. 
For example, we can
have more than one instance of the same route for different pieces of logic:

```perl
get qr!/user/[^/]+/course/([^/]+)! => sub {
    var course => (splat)[0];
    pass;
};

get qr!/user/[^/]+/course/[^/]+! => sub {
    # somebody's interested? better get organized
    $teacher{ $vars->{course} } ||= $profs[ rand @profs ];

    pass;
};
```

And, of course, since the power of regular expressions is at
our fingertips, we can also have any type of laterally-injected
piece of funkiness we can dream off:

```perl
get qr!/user/([^/]+)/course/\\1/! => sub {
    var homonym_discount => 1;
    pass;
};
```

As I said up top, this is probably old news for lots of people, 
but for me it's a big piece of the puzzle falling into place.
One that fills me with mirth. And maybe more than just a tad of 
nefarious glee. Me has a new toy to abuse. *Wheeeee!* 
