---
title: Varys' Little Birds
url: varys
format: markdown
created: 22 Jul 2012
tags:
    - Perl
---

One of the great joys of Perl and CPAN is how it allows you to stand on the
shoulders of giants. By picking the right tools, applications that are not
that trivial can be built in a matter of days, if not hours, and the goal of my
little project of today is to demonstrate that very thing. 

So. Grab a helmet and put your mouth-piece on, for this time I aim at nothing
else than to blow your mind to awestruck smithereens.

## The Specs

In a vague, semi-related follow-up to
[Dumuzi](http://babyl.dyndns.org/techblog/entry/system-monitoring-on-the-cheap), 
I was wondering last week if I could have system checks that I could install 
on different machines and query via a web server. Those checks would come with
two modes: passive checking, where we only collect information, and testing,
where we check if everything's peachy.

On top of that, why not have the results of the checks stored in a local history
database.  

And it would also really be good if I could also run the same checks,
with a minimum of code change. Or, since we're in full dream mode, maybe no
code change at all.

Sounds like a fair application. In those three little paragraphs, we managed
to squeeze needs for http, cli and database stacks, which need to be all put
together in a seamless way.  Okay. So, how many lines of code 
will be required to build that app (that, for giggles,
I'll call [Varys][varys]). Well, let's see...

[varys]: http://awoiaf.westeros.org/index.php/Varys

## A Check for Disk Usage

First thing, we need checks.  As a sample, we'll write one that reports on the 
disk partitions and, possibly, check that none is getting too full.

<galuga_code code="perl">DiskUsage.pm</galuga_code>


Checks are going to be what we write over and over again, so we want to make
it as easy to use as possible.  All we are expecting from it are attributes
that can either be parameters passed to the check (labeled via the *Input*
trait), or collected data (labeled via the *Info* trait). Plus a `test()`
function that will return a hashref with a *success* result, and whatever
other information we want to provide (in this case, the list of bloated
partitions).

In truth, the only piece of boilerplate that we need is the 
`class_has '+store_model'` stanza, which is required as we
are going to use the `DBIx::NoSQL::Store::Manager` system 
I put together a [few weeks
ago](http://babyl.dyndns.org/techblog/entry/shaving-the-white-whale).
But more details on that later on.

## The Checks Inner Mechanisms

Of course, checks don't run on pure pixie magic. It's **close** to it, but not
quite. The role of the sparkling dust, in this case, is played by the parent
class `Varys::Check`, which takes care of setting all the common stuff and
hook points for the overall systems that will be using those checks:

<galuga_code code="perl">Check.pm</galuga_code>

As you can see, we're using [MooseX::App::Cmd](cpan) for our cli
invocation of the checks. In consequence, we have to tweak things such that
the same class will not complain when used outside of that harness (lines
20-23), and we have to provide an `execute` method (line 92). 

We're also using that `DBIx::NoSQL::Store::Manager` add-on I wrote on top of 
[DBIx::NoSQL](cpan), so we also need to have a store key (lines 25-29).

The rest are things all checks will share: attributes for the name of the
check, the timestamp of when it is run, if the test has to be executed and
a last attribute to store the results of the said potential test, and the 
`info` method, which serialize the information of the check in a format we'll
be able to bandy around.

## The Web Service

For the web service, we are using dear lithe and nimble [Dancer](cpan):

<galuga_code code="perl">Varys.pm</galuga_code>

The brievity of the code talks for itself. For each check, we are creating a 
*GET* action (for simple information retrieval) and a *POST* action (for
running the test). A pre-serializing hook takes care that all results
are kept in our store, and the serializing itself is taken care of by Dancer 
and our checks' `info()` method. Oh yes, and we've thrown in some basic auth,
because letting anybody run stuff on your machines? Not smart.

The result:

<galuga_code code="bash">web1.log</galuga_code>


## The CLI Application

With what we already have, adding the cli application is only a question of
throwing a script called `varys.pl`:

<galuga_code code="perl">varys.pl</galuga_code>

Yup, just that. And with that, we can now do:

<galuga_code code="bash">cli.log</galuga_code>

## Tadah!

Aaaand that's it for now.  The code, as usual, is available on
[GitHub](https://github.com/yanick/varys). 
The `DBIx::NoSQL::Store::Manager`-related classes are still hidden in
my [Galuga](https://github.com/yanick/galuga) project, but should be CPANized
in a not-so-distant future. 
