---
created: 2013-06-06
tags:
    - Perl
    - Twitter
---

# Are You Ready For the Atwitterpocalypse?

Aaah, nothing like a good, thick slab of 
histrionics to spruce up a blog entry title...

Ridiculously panicked titles aside, this is more of a reminder than a call to
stock up on soup cans and shotgun shells. Version 1 of Twitter's API is
scheduled to be put to REST (*\*snickers\**) on [June 11th][rest], which means
that if your applications are still using the old API, now would be a good
time to upgrade to v1.1. 

## Is your code ready...?

If you are using [Net::Twitter](cpan), that
might be as easy as changing:

    #syntax: perl
    my $nt = Net::Twitter->new(
        traits   => [qw/API::REST/],
        consumer_key    => $consumer_key,
        consumer_secret => $consumer_secret,
        access_token    => $token,
        access_token_secret => $token_secret,
    );

to

    #syntax: perl
    my $nt = Net::Twitter->new(
        traits   => [qw/API::RESTv1_1/],
        consumer_key    => $consumer_key,
        consumer_secret => $consumer_secret,
        access_token    => $token,
        access_token_secret => $token_secret,
    );

While they shouldn't affect most use-cases, there **are** a differences
between the two APIs. To know all about them, check out 
[Net::Twitter::Manual::MigratingToV1_1](https://metacpan.org/module/MMIMS/Net-Twitter-4.00006/lib/Net/Twitter/Manual/MigratingToV1_1.pod).

## ... how about your web framework and its plugins?

I got my own wake-up call when berekuk poked me about
[Dancer::Plugin::Auth::Twitter][ticket], which was still using v1.0 of the
API. Direct result: [Dancer-Plugin-Auth-Twitter v0.05][dpat] and 
[Catalyst-Authentication-Credential-Twitter v2.0.0][cat] are both on their way
to CPAN, both updated to use v1.1 of the REST API. If you are using one or the
other, I highly recommend that you upgrade. Preferably, y'know, before June
11th.

[rest]: https://dev.twitter.com/blog/api-v1-retirement-date-extended-to-june-11
[ticket]: https://github.com/PerlDancer/Dancer-Plugin-Auth-Twitter/pull/7
[dpat]: https://metacpan.org/release/Dancer-Plugin-Auth-Twitter
[cat]: https://metacpan.org/release/Catalyst-Authentication-Credential-Twitter

