---
title: A First Foray Into Hadoop Territory
url: first-hadoop-foray
format: markdown
created: 8 Jul 2012
modified: 19 Jul 2012
tags:
    - Perl
    - Hadoop
---

I was peacefully minding my own business on Friday, when suddenly the
heavens parted and, lo and behold, the archangel Gabriel, all wings and
flaming sword of God, descended unto Earth right in front of me and said, in a
voice that sounded like a thousand mating bullfrogs: "Yo, dude: Hadoop. Learn
it."

"Uh, sure," was my answer. "Any particular reason why?"

"Final Battle's coming in. Humanity'll need you," was the terse answer. And
then he vanished, in a blast of prismatic colors and cherubic high notes.

So, there you have it in exclusivity. Armageddon's officially coming, and
it's safe to assume that it won't be exactly as described in the Book of
Revelations. 

Oh, yeah, and I'm now playing around with Hadoop.

## What's a doop?

[Hadoop][hadoop] is a framework to deal with the processing of massive amounts
of data. And by massive, I really mean more than just big. I mean
levianthanesque in scope, the kind of humongous size that can only be put in
context by a *Yo mama* joke.

As far as I can make it out, Hadoop's fundation lies on not one, but two types
of special sauces. The first is the *Hadoop Distributed File System* (HDFS), which provides
high-throughput access to the data, and *Hadoop MapReduce*, the software
framework allowing the processing of those masses of data. After a quick first
peek at it, the latter feels to me like Perl's `map` function re-imagined by
an engineer of the Death Star. Sounds promising to me.

[hadoop]: http://hadoop.apache.org/

## First Poke: Hadoop's Streaming Interface

Before I would dig into the mechanics under the hood of the hadoop
beastie (which is the part, I assume, that is going to be heady as hell), 
I thought it would be a good idea to play a little bit with some of its
applications to give me a feel for the lay of the land.

The first that I wanted to try was the [streaming interface][streaming] to
*MapReduce*. Basically, it's an API that allows Hadoop to use
any script/program to perform the mapping/combining/reducing parts of the job.
Yes, any program, in any language. I already thought what you are thinking,
and am in fact one step further: I found [Hadoop::Streaming](cpan) which
is going to make the exercise one sweet, smooth ride in the park.

The classic *Hello World* application for MapReduce seems to be counting
instances of words in a document. It's nice, but let's try to spruce it up a
(itsy-bitsy) notch. How about figuring out what is the first instance I ever
mentioned different modules in my blog entries?

The first, non-Hadoop, step that we need to do is to stuff all blog entries in
a single document, alongs with its creation date and its filename. That ain't
too hard to do:

<galuga_code code="perl">gather_entries.pl</galuga_code>

With that, we can create our master file and drop it in Hadoop's cavernous
file system:

    #syntax: bash
    $ ./gather_entries.pl > all_blog_entries
    $ hadoop fs -put all_blog_entries all_blog_entries

Now, we'll need two scripts for our data munging. A `mapper.pl`, to extract
all module name / filename and creation time pairs:

<galuga_code code="perl">mapper.pl</galuga_code>

And a `reducer.pl`, to produces the earliest blog entry:

<galuga_code code="perl">reducer.pl</galuga_code>

With that, we are ready to unleash the might of Hadoop:

    #syntax: bash
    $ hadoop jar /path/to/hadoop-streaming-1.0.3.jar  \
        -D          mapred.job.name="Module Mentions" \
        -input      all_blog_entries                  \
        -output     oldest_blog_entries               \
        -mapper     `pwd`/mapper.pl                   \
        -reducer    `pwd`/reducer.pl
    packageJobJar: [/tmp/hadoop-root/hadoop-unjar1363307178676659245/] [] /tmp/streamjob451754843805661903.jar tmpDir=null
    12/07/08 20:23:36 INFO util.NativeCodeLoader: Loaded the native-hadoop library
    12/07/08 20:23:36 WARN snappy.LoadSnappy: Snappy native library not loaded
    12/07/08 20:23:36 INFO mapred.FileInputFormat: Total input paths to process : 1
    12/07/08 20:23:36 INFO streaming.StreamJob: getLocalDirs(): [/tmp/hadoop-root/mapred/local]
    12/07/08 20:23:36 INFO streaming.StreamJob: Running job: job_201207071321_0014
    12/07/08 20:23:36 INFO streaming.StreamJob: To kill this job, run:
    12/07/08 20:23:36 INFO streaming.StreamJob: /usr/libexec/../bin/hadoop job  -Dmapred.job.tracker=localhost:9001 -kill job_201207071321_0014
    12/07/08 20:23:36 INFO streaming.StreamJob: Tracking URL: http://localhost:50030/jobdetails.jsp?jobid=job_201207071321_0014
    12/07/08 20:23:37 INFO streaming.StreamJob:  map 0%  reduce 0%
    12/07/08 20:23:51 INFO streaming.StreamJob:  map 100%  reduce 0%
    12/07/08 20:24:03 INFO streaming.StreamJob:  map 100%  reduce 100%
    12/07/08 20:24:09 INFO streaming.StreamJob: Job complete: job_201207071321_0014
    12/07/08 20:24:09 INFO streaming.StreamJob: Output: oldest_blog_entries

    $ hadoop fs -cat oldest_blog_entries/part-00000 | head
    A::B    template-declare-import/lib/A/B.pm (322.057893518519)
    Acme::Bleach    pythian/dpanneur-your-friendly-darkpancpan-proxy-corner-store/entry (654.046655092593)
    Acme::Buffy     use.perl.org/31870.d/entry (574.224444444444)
    Acme::Dahut     use.perl.org/dahuts/entry (575.121782407407)
    Acme::EyeDrops  pythian/dpanneur-your-friendly-darkpancpan-proxy-corner-store/entry (654.046655092593)
    Algorithm::Combinatorics        nocoug-2012-sane/files/party_solver.pl (27.0165972222222)
    Apache::AxKit::Language::XPathScript    shuck-and-awe/issue-11/entry (654.046643518519)
    Apache::XPointer::XPath shuck-and-awe/issue-11/entry (654.046643518519)

Yeah, looks about right. And, just like that, we now have our first
application using Hadoop's MapReduce. Wasn't too painful, now, was it?

## Graduating to the Real Good Stuff

> **Edit:** As some people pointed out in the comments, I'm full of hooey. 
> Cassandra is not built on top of Hadoop but is a different beast altogether.
> I was lead astray by the Hadoop site listing Cassandra as one of the 
> Hadoop-related projects, which erroneously made me assume that they were, err,
> related instead of simply acquainted. Oh well. It's not like I'm not used to
> having wiggling toes tickling my uvula, and I wanted to play with everything 
> dealing with the Hadoop ecosystem anyway, so it's all good.

One of the yummy things about Hadoop is the applications already built on top
of it. For example, there is Cassandra, a 
scalable multi-master database with no single points of failure (translation:
even after a thermonuclear war your data will still probably linger around
to, no doubt, the everlasting glee of the lone surviving mutant cockroaches).

There is a few Cassandra modules on CPAN, but to start easy, I went with 
[Cassandra::Lite](cpan), which makes the basics very easy indeed:

<galuga_code code="perl">cass.pl</galuga_code>

Now, if you remember my [post of a few weeks back][nosql] where I used the
SQLite as a NoSQL database, you might realize that to alter that code to use
Cassandra instead od SQLite should be fairly easy. With just an itsy-bitsy
little bit of work, I could web-scale my blog writing.  

Which, okay, might be a tad overkill. 

But still. I *could*.

But first, I have other applications to try...

*To be continued*

[nosql]: http://babyl.dyndns.org/techblog/entry/shaving-the-white-whale
[streaming]: http://hadoop.apache.org/common/docs/r0.15.2/streaming.html
