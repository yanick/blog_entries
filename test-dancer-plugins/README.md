---
title: Mass-Testing Dancer's Plugins
url: test-dancer-plugins
format: markdown
created: 17 Sep 2012
tags:
    - Perl
    - Dancer
---

One of my highlights of [YAPC::EU 2012](http://act.yapc.eu/ye2012/) was to meet a few of the core 
Dancer dudes (and, yes, a blog entry about the conference is forthcoming, it
only has been delayed by two weeks of utterly decadent vacations in the heart
of the Rhine Valley). Amongst other things, dams filled me in on the progress
of Dancer 2, and what tasks still lay ahead before this rewrite of our
favorite micro-web framework can hit the streets. One of the items on the
to-do list is to verify that most of the plugins already written for Dancer 1
will still work for Dancer 2. *Well*, I thought, *that's just like doing [smoke
testing](http://en.wikipedia.org/wiki/Smoke_testing#Smoke_testing_in_software_development) 
for a small subset of Perl modules. How hard can it be?*

Yeah, I do tend to say silly things like that...

## Corraling the Modules

First task: gather the modules to test. Finding all of Dancer's plugins is
relatively simple. Mostly if your cpan client is configured to use the SQLite
backend:

    #syntax: bash
    $ sqlite3 ~/.cpan/cpandb.sql 'select dist_name from dists \
        where dist_name like "Dancer-Plugin%"' \
        | perl -pe's/-/::/g' > plugins

If the output of that command is to be trusted, there are 76 Dancer plugins
out there. Not a bad number. For keeping them around, I decided to have a go at [Pinto](cpan), which
turned out to be a joy.

    #syntax: bash
    perl -ne'chomp; next if /^\s*#/; `pinto -v pull $_`' plugins

Mind you, the command could have been as simple as

    #syntax: bash
    pinto -v pull < plugins

but for two things: I wanted to be able to comment out problematic plugins in
the list and skip over them, and it seems that Pinto would abort commiting all
of the pulled distributions if one of them goes wrong. And while pulling 76 distros
and all their dependencies **did** generate a lot of wrongness, so calling
pinto on each plugin independently was the fastest way out.

## Testing the Herd

With all the modules nicely accessing, I thought I had it done. 

AH! 

It turns
out that while Perl has an awesome ecosystem for testing, it's also quite
befuddling at first, and most of the modules are almost but not quite what I
was wanting. To wit: they are mostly aimed at smoking ALL THE THINGS on
potentially many perls, and push the results to a smoking mothership rather
than feed a local database.  A specific module,
[SmokeRunner::Multi](cpan), seemed more promising for the task, and could
even talk to a [Smolder](cpan) instance. ... well, to make a long story
short, at the end I didn't use it (although I still keep it on the wing), but
I ended up becoming its maintainer. Just don't ask me how that happened.

What I ended up doing, instead, is leverage the `--test-only` option of
`cpanm`. I haven't found a way yet to use it in such a way that I would get
the full TAP results for a distro (although I'm sure there's a way),
but it reports the overall success or failure, which is already a start.

So, I have a way to test the modules. Now, I need to store the results. How
about going easy and sleazy and using that `DBIx::NoSQL::Store::Manager` I
[hacked a few months
back](http://babyl.dyndns.org/techblog/entry/shaving-the-white-whale)?
(No, it's not on CPAN yet. Yes, I'm going to do something about that Real
Soon<sup>tm</sup>) 

<galuga_code code="perl">DancerTest.pm</galuga_code>

<galuga_code code="perl">Types.pm</galuga_code>

<galuga_code code="perl">Plugin.pm</galuga_code>

And with that in hand, we just need one more script to turn in the crank:

<galuga_code code="perl">test_one.pl</galuga_code>

Aaaand:

    #syntax: bash
    $ ./test_plugins.pl plugins 
    testing Dancer::Plugin::ExtDirect
    \ {
        __CLASS__      "DancerTest::Model::Plugin",
        dancer1_pass   1,
        dancer2_pass   1,
        name           "Dancer::Plugin::ExtDirect",
        timestamp      "2012-09-18T01:41:52",
        verbose        1,
        version        1.03
    }
    testing Dancer::Plugin::TTHelpers
    \ {
        __CLASS__      "DancerTest::Model::Plugin",
        dancer1_pass   1,
        dancer2_pass   1,
        name           "Dancer::Plugin::TTHelpers",
        timestamp      "2012-09-18T01:42:01",
        verbose        1,
        version        0.004
    }


Final stroke, reporting the latest results:

<galuga_code code="perl">reporting.pl</galuga_code>

Which gives us:

    #syntax: bash
    $ ./report.pl                                            
                                      distro    version   dancer_1   dancer_2
                   Dancer::Plugin::SQLSearch       0.04     passed     failed
                        Dancer::Plugin::I18N       0.40     passed     failed
                        Dancer::Plugin::Lucy      0.001     passed     passed
                    Dancer::Plugin::EmptyGIF        0.3     passed     failed
                      Dancer::Plugin::Locale       0.01     passed     passed
            Dancer::Plugin::Locale::Wolowitz   0.122470     passed     failed
                  Dancer::Plugin::RequireSSL   0.121370     passed     passed
                         Dancer::Plugin::Res     0.0003     passed     passed
                     Dancer::Plugin::Lexicon       0.05     passed     passed
                    Dancer::Plugin::Cerberus       0.03     passed     passed
                    Dancer::Plugin::Resource   1.122280     passed     failed
                Dancer::Plugin::ElasticModel       0.05     failed     failed
                    Dancer::Plugin::Database       1.82     passed     failed
                       Dancer::Plugin::Email     0.1300     passed     passed
                      Dancer::Plugin::Scoped    0.02fix     passed     passed
                     Dancer::Plugin::SiteMap       0.11     passed     passed
                        Dancer::Plugin::DBIC     0.1506     passed     failed
                   Dancer::Plugin::Authorize   1.110720     passed     passed
               Dancer::Plugin::FormValidator   1.122460     passed     failed
       Dancer::Plugin::Params::Normalization       0.51     passed     failed
                        Dancer::Plugin::REST       0.07     passed     failed
                       Dancer::Plugin::Mongo       0.03     passed     failed
                    Dancer::Plugin::ORMesque   1.113100     passed     failed
                     Dancer::Plugin::Browser        0.4     passed     passed
                   Dancer::Plugin::DebugDump       0.03     passed     passed
                   Dancer::Plugin::Memcached       0.01     passed     failed
                         Dancer::Plugin::MPD       0.03     failed     failed
                        Dancer::Plugin::Feed        0.8     passed     failed
                Dancer::Plugin::MobileDevice       0.03     passed     failed
                  Dancer::Plugin::Auth::RBAC   1.110720     passed     failed
               Dancer::Plugin::Auth::Twitter       0.02     passed     failed
                  Dancer::Plugin::SimpleCRUD       0.61     passed     failed
      Dancer::Plugin::SporeDefinitionControl       0.11     passed     failed
                   Dancer::Plugin::WebSocket     0.0100     passed     failed
                       Dancer::Plugin::Redis        0.2     passed     failed
             Dancer::Plugin::FormattedOutput       0.01     passed     passed
                Dancer::Plugin::FlashMessage      0.314     passed     failed
               Dancer::Plugin::MemcachedFast   0.110770     passed     failed
                    Dancer::Plugin::Facebook      0.900     failed     failed
             Dancer::Plugin::ValidationClass   0.120490     passed     failed
                   Dancer::Plugin::ProxyPath       0.03     passed     failed
                   Dancer::Plugin::GearmanXS   0.110570     failed     failed
                   Dancer::Plugin::FlashNote      1.0.3     passed     failed
                         Dancer::Plugin::SMS       0.01     passed     passed
              Dancer::Plugin::Fake::Response       0.03     passed     failed
                  Dancer::Plugin::Cache::CHI      1.3.0     passed     failed
                    Dancer::Plugin::Progress      0.001     passed     passed
                Dancer::Plugin::TimeRequests       0.03     passed     passed
                       Dancer::Plugin::Async      0.001     passed     passed
                    Dancer::Plugin::XML::RSS       0.01     passed     passed
    Dancer::Plugin::Auth::RBAC::Credentials::DBIC      0.003     passed     failed
                  Dancer::Plugin::Passphrase      1.0.0     passed     failed
                Dancer::Plugin::ValidateTiny       0.05     passed     passed
                       Dancer::Plugin::Hosts       0.01     passed     passed
                      Dancer::Plugin::Bcrypt      0.4.1     passed     failed
                       Dancer::Plugin::Stomp     1.0101     passed     passed
                Dancer::Plugin::LibraryThing     0.0003     passed     passed
                Dancer::Plugin::DebugToolbar      0.016     passed     failed
                  Dancer::Plugin::EscapeHTML       0.22     passed     failed
                    Dancer::Plugin::EncodeID       0.02     passed     failed
               Dancer::Plugin::DirectoryView       0.02     passed     failed
                     Dancer::Plugin::NYTProf       0.21     passed     passed
                 Dancer::Plugin::Auth::Basic       0.02     failed     failed
                    Dancer::Plugin::Mongoose    0.00002     passed     failed
                  Dancer::Plugin::Dispatcher       0.12     passed     failed
            Dancer::Plugin::Preprocess::Sass       0.01     passed     passed
              Dancer::Plugin::Auth::Htpasswd      0.014     passed     passed
               Dancer::Plugin::ElasticSearch      0.002     passed     passed
                   Dancer::Plugin::ExtDirect       1.03     passed     passed
                   Dancer::Plugin::TTHelpers      0.004     passed     passed

According to the report, 37 plugins
pass their test under Dancer 1, but not Dancer2. Now we know exactly what work
remains to do. So... Let's get crackin'.


