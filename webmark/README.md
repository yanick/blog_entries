---
title: Web Framework Benchmarking Framework
url: webmark
format: markdown
created: 2015-06-25
tags:
    - Perl
---

Something that I had in my backlog for a long time is 
a way to easily benchmark web frameworks. Of course,
there is the [TechEmpower benchmark](https://www.techempower.com),
but I wanted something a little easier to set up and to play with. 

Today I finally got around throwing together a [very rough
prototype](http://github.com/yanick/webmark). Here is what it
looks like.

## The Benchmark scenarios

One thing I wanted for the benchmarking scenarios, and the benchmarking code
at large, is to be totally agnostic of the web framework used. In fact, I want
to allow the application to be something else than Perl. 

I also wanted the test to be able to verify the responses from the 
web appplication (because, hey, speed is good, but sane responses are better).
And simplicity, I wanted scenarios to be dead easy to write and run.

So what I did was to establish that each scenario would be a class consuming
the `Webmark::Scenario` role. The role would give you a `Test::WWW::Mechanize`
object to interact with the app, and requires the implementation of a single
method `speedtest`. That method receives a single argument that tells it to
either verify the responses of the app, or just go full speed.

For example, here's a basic scenario that verifies that the web app is alive and replies with
"hello world!".

```perl
package Webmark::Scenario::HelloWorld;

use 5.20.0;

use strict;
use warnings;

use Moose;

use experimental 'signatures';

with 'Webmark::Test';

sub speedtest ($self,$test=0) {
    $self->mech->get('/');

    $self->mech->content_is('hello world') if $test;
}

1;
```

Or, if we want something just a tad more complex, here's one that asks the
web app to come up with a JSON list provided a `from` and `to` parameters:

```perl
package Webmark::Scenario::CountUp;

use 5.20.0;

use strict;
use warnings;

use Moose;

use experimental 'signatures';

use JSON qw/ from_json /;
use Test::More;

with 'Webmark::Test';

sub speedtest ($self,$test=0) {
    my $m = $test ? 'get' : 'get_ok';

    for my $from ( 1..10 ) {
        for my $to ( $from..10 ) {
            $self->mech->$m("/?from=$from;to=$to");
            if ( $test ) {
                my $result = from_json( $self->mech->content );
                is_deeply $result => [ $from..$to ];
            }
        }
    }
}

1;
```

The only thing that I want to point out in that code is how I use
`Test::More`ish tests. That's because I wanted the assertions
to be a short and sweet as possible, and leverage all the goodness
of `Test::WWW::Mechanize` and good ol' `Test::More`. But beyond the fact that you can use
those functions, there's nothing really you need to know about how it works.
It just does. 

## Running the scenarios

Thank to most of the work being done being the curtain by
`Webmark::Scenario`, running a scenario is as simple as

```bash
$ ./bin/webmark.pl HelloWorld
{
   "running_time" : {
      "max" : 0.010209,
      "mean" : 0.00368558234165068,
      "min" : 0.002883,
      "nbr" : 2605,
      "std_dev" : 0.00286161032435765
   },
   "specs" : {
      "dancer_version" : "1.3139"
   }
}
```

Neat, isn't? And that's only the visible tip of what happens. Behind the
curtain, `webmark` does the following:

* It assumes that the web application is already running, either at
`http://localhost:3000` or at the url given via the environment variable
`WEBMARK_BASE`.
* It first tries to access the url `/specs`, which is expected to send any data
the application wants to share (neatly encapsulated in JSON, *por favor*).
* Then it does a first run of the `speedtest` in sanity-checking mode. If it
fails, it'll complains and stop right there.
* Then it runs the `speedtest` in non-checking mode for a certain period of
time (right now, 10 seconds because I'm an impatient man) and collect
statistics.
* Then it runs a sanity check again, juuuust in case the application had a
meltdown while being stress-tested.
* And outputs its data, in lovely JSON.

For the moment the statistics and specs returned are rather bare-bone, but
that's something that is easy to beef up as we go along.

It's probably fair to point out here that because I use `Test::WWW::Mechanize`
and some other stuff, the results are not only for the raw request/response time
of the web application itself, but also include a healthy dose of overhead. It's... regretable, but
not a deal-breaker, as long as we remember to compare the relative performance of the different
runs, and take their absolute values with a grain of salt.


## Launching the web apps

Aaaah, yes. This is the slightly more tricky part. And also the one I don't have
anything to show up for at the moment. Well, not totally true: I do have a proto-prototype, but
it's too ugly to share (and that coming from me should be a warning of its
potential mind-scarring hideousness).  

But I *do* have a vision of leveraging Ansible to take care of that. If each
application to test comes with its Ansible playlists to install its
dependencies and to launch/stop the application itself, not only it would open
the door to running those benchmarks on any and every framework one desires,
but also to run them on vagrant virtual machines for extra-reproducibility.
And the same idea can also be applied for the setting of more complex
scenarios that would involve databases and other local settings.

## And a few other things to consider

Once a certain pattern is set in place for Ansible playlists, the next obvious
step would be to have a uber-script that takes a scenario, set up the
scenario's condition on the designated VM, run `webmark` on a list of applications
and collect their stats. 

And the obvious step after that is to store those stats in a local database.

And after that, to have a web application graphing those results.

And after that, probably to write a scenario testing the performance of the
application graphing the performance of the scenarios.

And after that, well, after that I expect a visit from the men in white, and
probably some quality time in the padded room...

