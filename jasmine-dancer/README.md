---
title: Dancer + Jasmine
url: dancer-jasmine
format: markdown
created: 19 Mar 2015
tags:
    - Dancer
    - Perl
---

So I'm currently having fun learning [Angular](https://angularjs.org/).
Well, that's not exactly accurate. A few days ago I had fun learning Angular;
now I'm learning the whole surrounding JavaScript ecosystem. And oh boy are we
talking Amazonian-grade type of ecosystem -- turn a rock, any rock, and you
are guaranteed to have 5 new frameworks  scamper away.

Anyway, that's not the point. The point is, it's a new programming vista, but
some things don't change. Like the need to have tests. Although the backend of
my current project is [Dancer](cpan:release/Dancer)-based (natch), Angular
makes it a mostly front-end application. Just testing the Perl code won't do
(although, y'know, it's a good start). So, what to use to test the JavaScript
core of the application? Looking around, [Jasmine](http://jasmine.github.io/)
seemed to be a decent choice, so I decided to give it a whirl.

Turns out it's not too bad. And there are quite a few ways to run the tests.
But... How about *really* integrating those tests?

So I give you
[Dancer::Plugin::Test::Jasmine](gh:yanick/Dancer-Plugin-Test-Jasmine), which
auto-inject tests in your web pages. Lemme show you how.

First, you add the plugin configuration to your app `config.yml`:

    plugins:
        'Test::Jasmine':
            specs_dir: t/specs
            # lib_dir: /path/to/Dancer-Plugin-Test-Jasmine/share

Nothing outlandish, just the directory where the jasmine specs files
are. Plus optionally the directory where the jasmine libs are, although 
it can be omitted and provided directly by the plugin.

Then you `use` the plugin in the app. It'll give you two new keywords,
`jasmine_includes` and `jasmine_tests` which you must feed to your templates 
(I suspect I'll make that automagically dealt with in a subsequent version).

```perl
    package MyApp;

    use Dancer ':syntax';
    use Dancer::Plugin::Test::Jasmine;

    get '/' => sub {
        template 'index', { 
            jasmine_includes => jasmine_includes(),
            jasmine_tests =>  jasmine_tests(),
        };
    };

    ...;
```

Then in the templates you put `jasmine_includes` in the headers (it'll add
all the `<script>`s and `<link>`s for jasmine), and `jasmine_tests` 
at the end of the `<body>` (it'll inject the tests themselves).

And, basically, you're done. You can access the application normally:

![normal page](__ENTRY_DIR__/jasmine1.png)

But if you add `?test=sometest` to the url, that test will be loaded along the
page and executed. For example, provided  that you have the file
`t/specs/hello.js` being

```
describe("A testsuite", function() {
    it( "should report a success", function(){
        expect( $('h1:first').text() ).toBe('Perl is dancing');
    });
    it( "will fail", function(){
        expect( 0 ).toBeTruthy();
    });
});
```

you'll get

![page with test](__ENTRY_DIR__/jasmine2.png)


So all jasmine tests are now only a parameter away. Ain't that nifty?

But wait! There's more! 

This is quite nice for manual inspection and development assist.
But for full-on testing, I want to be able to automate the whole shebang.

Having Jasmine output its results in a easy-harvestable format is not hard --
there's a reporter that gives us a perfect good JSON representation to play
with. The tricky part is deciding how to run the application. 
We can't rely on good ol'
[Test::WWW::Mechanize::PSGI](cpan:release/Test-WWW-Mechanize-PSGI) alone as
the tests need to go through a JavaScript engine.  There is always
[Test::WWW::Selenium](cpan:release/Test-WWW-Selenium), but we'll go one step
further and use
[WWW::Mechanize::PhantomJS](cpan:release/WWW-Mechanize-PhantomJS), so that we
don't have to deal with a Selenium server nor a browser. How do we do it? Like
that:

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

And here what it spits out:

```
    # Subtest: jasmine test
    # duration: 0.005s
    not ok 1
        # Subtest: A testsuite
        # duration: 0.005s
        not ok 1
            # Subtest: should report a success
            # duration: 0.003s
            ok 1
            1..1
        ok 2 - should report a success
            # Subtest: will fail
            # duration: 0.001s
            not ok 1
            1..1
            # Looks like you failed 1 test of 1.
        not ok 3 - will fail
        1..3
        # Looks like you failed 2 tests of 3.
    not ok 2 - A testsuite
    1..2
    # Looks like you failed 2 tests of 2.
not ok 1 - jasmine test
1..1
# Looks like you failed 1 test of 1.
```

TA-DAAAH!
