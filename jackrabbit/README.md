---
url: jackrabbit
format: markdown
created: 2013-09-06
tags:
    - Perl
    - XML::Rabbit
    - JSON
---

# JSON::Rabbit - What's Up, Doc^D^D^D Serialized Data?

<div style='float: right; text-align: center'>
<img src="__ENTRY_DIR__/jackrabbit.jpg" alt="JSON::Rabbit, aka Jackrabbit"
width="300" />
<div style="font-size: small">
original picture by <a href="http://www.flickr.com/photos/nwcouncil/7362698874">nwcouncil</a>
</div>
</div>

Hello you lovelies. Missed me?

I know: I'm terrible. I don't call, I don't write, I barely breach on IRC.
For a man who vowed to hurl blog entries at the world as so many technolotov
cocktails, I sure keep my messages in a bottle scarce and far in-between.
But... I plead attenuating circumstances?
First, there was some RL thingies. And then I saw myself changing gears
big time at $work, shifting from the Perl dev side to the Big Data world. 
For a few weeks I had to get reacquainted with Java and, finally, had a good reason
to sit down and learn Python. And I also had to brush up my Hadoop. And my
Hive. And about a thousand other things. 

And for the slivers of time left, they pretty much got gobbled up by ongoing
Perl activities -- mostly some curating for the
[PerlWeekly](http://perlweekly.com) newsletter and the stewardship of Dancer
1's maintenance releases. 

Oh yeah, and I think that at some point it was also Summer.

Anyway. All that to say that I'm still around. Silent, perhaps, but
not still. Not blabbering, but definitively busy. And talking of which...
enough about me. Let's talk about harebrained schemes, shall we?

## Bunnies!

One of the things that is on my todo list is the recording of my comic book
collection into [Tellico](http://tellico-project.org/). Of course, entering
all data by hand is insufferably tedious, so I began to poke around Tellico's
import plugins. Not finding 
a good one for comics, I began to build one myself using the
[ComicsVine web service](http://www.comicvine.com/api/).

But that's actually the topic of a future blog entry.

What's important is that while I was working on that project, I remembered
the very nice [XML-Rabbit](cpan:release/XML-Rabbit), and thought how cool it would be to have 
a JSON equivalent. Mostly because I prefer much more JSON to XML for
serialization of data (XML's node attributes and content are wonderful for 
documents, but terribly ambiguous where serialization is concerned). But also
because... well, I thought how cool it'd be.

Parsing JSON itself, compared to XML, would be a piece of cake. The tricky
part would be more `XML::Rabbit`'s XPath-shaped heart. A JSON counterpart would need an
equivalent language to query the document to be viable. So I looked around
and, ooooh, lookee there at [JSON::Path](cpan:JSON::Path). 

With those tools in hand, at a high level all I had left to do was to replace
all mentions of `XML` for `JSON`, and all mention of `XPath` for `JPath`.
Basically:

``` bash
$ find lib -name '*.pm' -exec perl -i -pe's/XML/JSON/g; s/X(?=Path)/J/g;' {} \;
```

Well, as incredibly as it can sound, and thanks to Robin's gloriously sane OO models, this is almost all
that it took to get things running. Sure, XML namespaces also had to be pushed on
the side, and some functions had to be massaged, but after a surprisingly
small amount of surgical dabs, I was able to take

``` perl
use 5.16.0;

use strict;
use warnings;
 
package ComicsVine::Issue;
use JSON::Rabbit::Root;
 
has_jpath_value 'issue_number' => '$..issue_number';
 
has_jpath_object 'volume' => '$..volume' => 'ComicsVine::Issue::Volume';
 
has_jpath_object_list 'persons' => '$..person_credits[*]',
    'ComicsVine::Issue::Person', 
    handles => {
        all_persons => 'elements',
    };
 
finalize_class();
 
package ComicsVine::Issue::Volume;
use JSON::Rabbit;
 
has_jpath_value 'name' => '$.name';
 
finalize_class();
 
package ComicsVine::Issue::Person;
use JSON::Rabbit;
 
has_jpath_value 'name'   => '$.name';
 
finalize_class();
 
package main;

use JSON::Rabbit;

my $issue = ComicsVine::Issue->new( file => 'sample.json' );

say "issue number ", $issue->issue_number;
say "volume: ", $issue->volume->name;
say "credits: ", join ', ', map { $_->name } $issue->all_persons;
 
```

and get

``` bash
$ perl -Ilib sample.pl 
issue number 2
volume: Ambush Bug
credits: Anthony Tollin, Bob Oksner, John Costanza, Julius Schwartz, Keith Giffen, Robert Loren Fleming
```

And that, my friends, deserves a bunnirific  *Tadah!*.

<div align="center">
<img src="__ENTRY_DIR__/rabbitjuggler.jpg" alt="Tadah! Rabbits!" />
</div>

## And Now, We'll Need Help From the Audience

The code as it is now lives on a branch of my [GitHub fork of
XML-Rabbit](https://github.com/yanick/XML-Rabbit/tree/jackrabbit). It,
however, will need some polishing before it
can make its appearance on CPAN as `JSON::Rabbit` (pronounced '*jackrabbit*').
Sure, the happy path showed in the example
works beautifully, but there's still a fair share of functions to fix. And
there is the documentation to tweak for its new JSON context. And the test
suites to convert. Nothing hard, really, just a lot of handle turning.

Which ties with the scarcity of my tuits, round or of any other shape.
Eventually, I'll make the rabbit jump out of the hat, but if anyone is willing
to help the process could go a lot faster. Sooo... If you are interested for
co-maintenance of the furry wee beast, or just want to help with a bit of it,
please, poke me, fork the repo and... let the PRs hit the floor.
