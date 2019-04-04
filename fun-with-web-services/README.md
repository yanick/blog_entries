---
title: Building Web Service APIs
url: fun-with-web-services
format: markdown
created: 3 July 2012
tags:
    - Perl
    - WWW::Ohloh::API
---

A couple of years back, I created [WWW::Ohloh::API](cpan) because it
seemed to be a fun thing to do. And, trust me, it was.  But now, since I'm not using that 
module personaly, I thought it would be a good idea to see if anyone would be 
willing to co-maintain it. Before I could do that, though, there was two
little matters I had to deal with.

The first was the general problem that there is real CPAN equivalent of the
good ol' church steps on
which one could leave modules in a wicker basket for adoption. So... well... 
I kinda [proposed one](http://babyl.dyndns.org/techblog/entry/help-wanted).
The [Dist::Zilla](cpan) part of the deal is by now [out
there](https://metacpan.org/release/Dist-Zilla-Plugin-HelpWanted), and peeps
so far made favorable noises regarding the [MetaCPAN pull
request](https://github.com/CPAN-API/metacpan-web/pull/612), so there are good
chances that we'll see some *Help Wanted* signs popping in on MetaCPAN soon.
On that front, everything's groovy.

The second matter is less meta. Back in the days I first wrote
`WWW::Ohloh::API`, I was a big proponent of [Object::InsideOut](cpan).
Heck, I even have a `use.perl.org` [blog entry of that
time](http://use.perl.org/use.perl.org/_Yanick/journal/36961.html) where I
profess a preference of `O::IO` over [Moose](cpan). Come to think of it, those were also the years where I
was also going with `Prototype` over `jQuery`. And when I was going with 
[Rose::DB::Object](cpan) instead of [DBIx::Class](cpan).

No, I don't win a lot at
horse racing either, why are you asking?

Seriously, though, `Object::InsideOut` was -- and
still is -- great pieces of code. But it's fair to say 
that the aleas of fate have pushed it to the margins of the Perl
OO world. So I thought that to increase `WWW::Ohloh::API`'s chances 
to be adopted, I should pass it through a `Moose` make-over (let's call
it *Extreme Makeover: Antlered Edition*). 

So I did. And now, if you allow me, I'll babble a wee bit about its
refurbished modus operandi as not only it makes a great hook for wannabe
co-maintainers, but I think it's also an interesting foray into the
implementation of web services.

## Ohloh's web service

Before we dive in, we should probably take a step back and give the broader
picture. [Ohloh](https://www.ohloh.net/) is a social software directory 
website where one can create "stacks" listing the software they are using,
as well as send kudos to the peeps working on them. It also has a REST 
API, which is decently [documented](http://meta.ohloh.net/getting_started/).

The REST API is fairly standard, and 
supports two types of requests. One for single "objects" (projects, accounts,
etc.), and another for collections of those objects.

To interact with that API, I also went a fairly standard way. I decided that I
would have a main *WWW::Ohloh::API* object that would take care of the 
interactions with the REST service proper, and several
*WWW::Ohloh::API::Object::* and *WWW::Ohloh::API::Collection::* objects that
would reflect the different results that the web service provides.  Of course,
I could have done less fancy (and much easier) by returning a more generic
hash on all requests (like, for example, [MetaCPAN::API](cpan)) but, hey,
I like fancy.

## The main `WWW::Ohloh::API` class

Funnily enough, the main class is perhaps the simplest of the whole
distribution.  At its core, it's very little more than a thin wrapper around 
[LWP::UserAgent](cpan).

<galuga_code code="perl">www-ohloh-api.pm</galuga_code>

There is precious little magic in that code. I'm using 
[Module::Pluggable](cpan) to auto-discover all
the object and collection classes implemented (which is a little 
sloppy, but sure gets things going quickly), and implemented a main 
`fetch()` method to create all the result objects without having
to pass the main object over and over again.

Beside that, `_query_server()` and `_fetch_object()` take care
of the core functionality. Namely, take an uri, query the Ohloh server,
make sure the returned xml answer is kosher, parse it and return
its resulting dom representation.

So far, so good.

## An object class

Next on the line, the classes representing the different objects. Let's take
for our example
`WWW::Ohloh::API::Object::Account`, which implements an [account](http://meta.ohloh.net/referenceaccount/):

<galuga_code code="perl">www-ohloh-api-object-account.pm</galuga_code>

Much shorter than what you expected, eh?

There are two juicy pieces of role-fu at work here.  The first one 
is `WWW::Ohloh::API::Role::Fetchable`, which takes care of the 
nitty-gritty details of retrieving and storing the data fetched
from the web service. We'll see it in its full glory shortly, but for now
all we need to know is that it adds a `request_url` attribute to the class.
The principal piece a class that consumes that role requires is a wrapper
around the builder of that attribute that properly populates the path of that
url (I dare you to say that sentence thrice without spitting all over your
monitor).

The second one is the `XMLExtract` trait that grabs the value for the
attribute straight out of the xml returned by the service.  Of course,
for more complex sub-structures, like the `kudo_score`, or 
related objects that require a second request, like the `stack`, one has to
work a little bit more, but it's still all very manageable.

## A collection class

For the collections, a little more work has to be done. Not in the collections
classes themselves, mind you, which follow the same pattern but are even 
shorter (as they don't really have attributes by themselves):

<galuga_code code="perl">www-ohloh-api-collection-account-stacks.pm</galuga_code>

But they do rely on the `WWW::Ohloh::API::Collection` role which implement all
the work having to do with pagination behind the scene:

<galuga_code code="perl">www-ohloh-api-collection.pm</galuga_code>

The two key points in there are the local implementation of `fetch()`
which deal with the different xml structure returned by collections,
and the meddling with the request url that injects the paging parameters
for the subsequent `fetch()` calls to get a full collection.

## The keystone role

Underneath all of that lies the *Fetchable* role. One would expect a massive
work-horse here but, I'll let you see by yourself:

<galuga_code code="perl">www-ohloh-api-role-fetchable.pm</galuga_code>

Yup, that's it. It manages the agent that stores the main *WWW::Ohloh::API*
object, provides the scaffolding necessary to build the request url, and sets
a comfy nest for the xml structure that will be returned, and that's that.

## A last piece of candy: automatically extracting attributes from the xml

This last trait is the secret sauce that keeps all the object classes so DRY. 
It basically will populate its attributes with the xml element of the 
same name as found in *xml_src*. Of course, most of everything can be tweaked
as desired, but the defaults are already doing all we need in... well,
all the cases so far.

<galuga_code code="perl">www-ohloh-api-role-attr-xmlextract.pm</galuga_code>

## And that's it

Well, not quite. There are still some details like the definition of the 
different types and their coercion, but that's all banal stuff, and the
test version of the agent that uses local copies of the request urls. But we
have covered pretty much all the interesting, and remotely tricky, bits of
`WWW::Ohloh::API`. All there is left to do is to turn the crank and 
write the different classes. And document them. It's not terribly hard, but
there is an awful lot of them.

So... who wants a co-maint bit? 

... 

Guys?
