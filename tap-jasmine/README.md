---
title: Seamless Mesh of JS Tests With Perl Harness? Yes.
url: tap-jasmine
format: markdown
created: 30 may 2015
tags:
    - Perl
---

In my [previous blog entry][recap] on the topic, I shown how I
use [Dancer::Plugin::Test::Jasmine](cpan:module/Dancer::Plugin::Test::Jasmine)
to auto-run [Jasmine][jasmine] tests on pages served by a Dancer app.
I also shown how those tests could be run as automated Perl-based tests,
using [Test::TCP](cpan:module/Test::TCP) to fire up the Dancer application,
and [WWW::Mechanize::PhantomJS](cpan:module/WWW::Mechanize::PhantomJS) to
run the tests within the app page, collect the results, and pipe them back as
TAP.

All of that is, if I can say so myself, pretty nifty. But in the meantime, 
I've found that there was room for improvement. And, well, improvement
happened. Here, let me show you.

## Lose the boilerplate

If you remember, at the end of the last blog entry the test script to 
run a Jasmine spec file looked like

```perl
use strict;
use warnings;

use Test::More;

use JSON qw/ from_json /;

use Test::TCP;
use WWW::Mechanize::PhantomJS;
use Dancer::Plugin::Test::Jasmine::Results;

Test::TCP::test_tcp(
    client => sub {
        my $port = shift;

        my $mech = WWW::Mechanize::PhantomJS->new;

        $mech->get("http://localhost:$port?test=hello");

        jasmine_results from_json
            $mech->eval_in_page('jasmine.getJSReportAsString()'; 
    },
    server => sub {
        my $port = shift;

        use Dancer;
        use MyApp;
        Dancer::Config->load;

        set( startup_info => 0,  port => $port );
        Dancer->dance;
    },
);

done_testing;
```

This is all fine and dandy. Until I realized that for each of my `spec` test file, I'd
have to copy that boilerplate-heavy test where I'd only change the name of the
test. Of course, I could put most of the code in a library and reduce the test
scripts to

``` perl
use lib 't/lib';
use Test::Jasmine;

test_jasmine( 'hello' );
```

but I'd still have to have a sister `.t` file for every spec file. That's a
pain. Wouldn't it be much nicer if the test harness could just see the spec
files and already know what to do? 

## Harness the power

We often forget it, but `prove` and the test harness can perfectly deal
with test files other than perl's `.t`s. As long as we tell them how to
do so. 

And the way to do it is to create a custom harness, like so:

``` perl
package SpecsHandler;

use strict;
use warnings;

use TAP::Parser::IteratorFactory;
 
use base 'TAP::Parser::SourceHandler';
 
TAP::Parser::IteratorFactory->register_handler( __PACKAGE__ );
 
sub can_handle {
    my ( $class, $src ) = @_;
 
    return $src->meta->{file}{lc_ext} eq '.js';
}
 
sub make_iterator {
    my ($class, $source) = @_;
    TAP::Parser::Iterator::Process->new({
        'command' => [ 't/bin/run_specs.pl', 
            join '', map { $source->meta->{file}{$_} } qw/ dir basename / 
        ],
    });
}
 
1;
```

Figuring out how to implement the handler from the docs was a challenge, but
the end-result is not terribly complicated. One function figuring out which
files it can process, and another to delegate its processing to a helper
script. Easy peasy.

To have `prove` use this handler in addition to its usual ones, I could do

```bash
$ prove --source SpecsHandler
```

(while making sure that `t/lib` is part of `PERL5LIB`, natch), but I decided
to just create the file `.proverc` in the root directory of my project 

```
# in .proverc

--source SpecsHandler
```

and be done with it.

## Run with it

Now, for `run_specs.pl` to run a Jasmine test, it must know the 
name of the spec file (which it receives from the handler), as well as the uri
of the page on which the test should run. Well, what better place to capture
that information than in the spec file itself?

```javascript
/**
 * @url  /uri/of/page/to/test
 */

describe( "blah", function(){
    it( "does things", () => { ... } );
});

```

As you may surmise, parsing that stuff is no problem. So, putting that
together with the code we already have, and `run_specs.pl` looks like:

```perl
#!/usr/bin/env perl 

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Path::Tiny;

my $specs_file = Path::Tiny::path(shift);
my $specs = $specs_file->slurp;

my( $target_url ) = $specs =~ /\* \s+ \@url \s+ (\S+) /x;
$target_url ||= '/';

use Dancer ':tests';

use JSON qw/ from_json /;

use Test::TCP;
use WWW::Selenium;
use Dancer::Plugin::Test::Jasmine::Results;

Test::TCP::test_tcp(
    client => sub {
        my $port = shift;

        my $mech = WWW::Selenium->new(
            host => 'localhost',
            port => 4444,
            browser => '*chrome',
            browser_url => "http://localhost:$port",
        );

        $mech->start;
        $mech->open("http://localhost:$port$target_url?test=" . $specs_file->basename('.js') );
        $mech->wait_for_page_to_load(5000);

        my $tries = 10;
        my $result;
        while ( $tries-- ) {
            sleep 1;
            $result = eval { $mech->get_eval('window.jasmine.getJSReportAsString()') }; 
            last if $result and $result ne 'null';
        }

        jasmine_results from_json $result;
    },
    server => sub {
        my $port = shift;

        diag "server running on port $port";

        set( startup_info => 0,  port => $port, apphandler => 'Standalone');
        Dancer->dance;
    },
);

done_testing;
```

(oh yeah, I switched to [WWW::Selenium](cpan:module/WWW::Selenium) while
nobody was looking, because phantomJS was causing me some grief.)

And, just like that,  with that script, plus the handler, plus the `.proverc`
file, plus a selenium server running on my machine, I can now do

```bash
$ prove t/spec/test_me.js
```

and the test will pop up a Firefox window, do its things, and report the
results back as part of the full test suite, all as clean and transparent
as you like. 

## It gets better

For my project, this setting was missing a last piece. As my application has a
database backend, I needed to be able to apply fixtures to the database before
I could run some of my tests. As I was already using
[Dancer::Plugin::DBIC](cpan:module/Dancer::Plugin::DBIC), it was pretty easy
to bring in [Test::DBIx::Class](cpan:module/Test::DBIx::Class)
and [DBIx::Class::Fixture](cpan:module/DBIx::Class::Fixture). Just like for
the page uris, I added a `@fixtures` line to the tests needing them:


```javascript
/**
 * @url  /uri/of/page/to/test
 * @fixtures customerA userB itemC
 */

describe( "blah", function(){
    it( "does things", () => { ... } );
});

```

and altered `run_specs.pl` to do the database dance before 
we run the test:

```perl
my $specs_file = Path::Tiny::path(shift);
my $specs = $specs_file->slurp;

my( $target_url ) = $specs =~ /\* \s+ \@url \s+ (\S+) /x;
$target_url ||= '/';

my ( @fixtures ) = map { split ' ', $_ } 
                       $specs =~ /\* \s+ \@fixtures? \s+ (.*) /gx;

use Dancer ':tests';

# use the information straight from the dancer config

use Test::DBIx::Class {
    schema_class => config->{plugin}{DBIC}{default}{schema},
    connect_info => [ map { config->{plugins}{DBIC}{default}{$_} } 
                          qw/ dsn user password / ],
    force_drop_table => 1,
};

use MyFixtures;

if ( @fixtures ) {
    diag "loading fixtures ", join ' ', @fixtures;

    MyFixtures->new( schema => Schema() )->load(@fixtures);
}

# the rest as before...
```

And that's it. Now my tests run, on the front-end, with whichever state of the
backend it needs, without me having to do anything special beyond `prove
t/spec.js`.

Life is good.


[jasmine]: http://jasmine.github.io/
[recap]: http://techblog.babyl.ca/entry/dancer-jasmine
