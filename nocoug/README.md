---
created: 2011-02-19 
original: the Pythian blog - http://www.pythian.com/news/20785/nocoug-sql-challenge-thinking-outside-the-padded-box
tags:
    - Perl
    - SQL
    - NoCOUG
    - golf
---

# NoCOUG SQL Challenge – thinking outside the padded box

Seems that our [André Araujo][1] has already spilled the beans and 
revealed [his solution][2] to the [second edition of the NoCOUG SQL
Challenge][3].

[1]: http://www.pythian.com/blogs/author/araujo
[2]: http://www.pythian.com/news/20757/nocoug-sql-challenge-entry-2/
[3]: http://www.nocoug.org/Journal/NoCOUG_Journal_201102.pdf

Now, I can’t let him have all the fun, can I?

Unfortunately, my SQL-fu is pathetically weak, so I stand no chance against his Querying Might. Buuut I am well versed in another art. A darker 
art. A terrifying art: [Perl golf][4].

[4]: http://en.wikipedia.org/wiki/Perl#Perl_golf

You might want to get the children out of the room before you continue
reading. Pregnant women and the elderly might also want to avert their eyes.
It ain’t going to be pretty.


... everybody with a weak stomach has left the premise?  Good.


To be able to work with it, I’ve exported the riddle table into a space-delimited file, looking like this:

    A
    COMPREHENSION ABILITY OLD
    ABOUT
    ALWAYS
    SCIENCE AND PHYSICS
    ANY
    AS
    ...

With the data in that format, I can now solve the riddle with:

```perl
#!/usr/bin/perl -p
s/ (\w+)/lc$&amp;/e;$k{$1}=$_}{/ /&amp;&amp;s/[A-Z]+/$k{$&amp;}/,$x[y---c]=$_
for(%k)x%k;$_=pop@x;
```

While this script prints the secret message, it’s not very well formatted. If we want to be prettier, we can always do:

    $ ./nocoug.pl data | perl -0lpe's/\s+/ /g'

For the time being, I’ll resist the urge to deconstruct and explain my solution. Instead, I’m going to add a meta-level to the challenge. Can you figure out how I’m solving the unspoken problem? And if you do, can you translate it into an Es-Cue-El invocation? While keeping some grasp on your sanity?
