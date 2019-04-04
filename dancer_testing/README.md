---
title: Testing Dancer Applications
url: testing-dancer
format: markdown
created: 24 August 2014
tags:
    - Perl
    - Dancer
---

So you wrote a [Dancer](cpan:release/Dancer) or 
[Dancer2](cpan:release/Dancer2) application and,
good programmer that you are, you want to test it. It's 
a kind of no-brainer that 
[Dancer::Test](cpan:module/Dancer::Test)/[Dancer2::Test](cpan:module/Dancer2::Test) is the module that you
should reach for, right? 

Well, maybe not.

The truth is, Dancer::Test was created as necessary collateral when Dancer came to be.
But since then a few PSGI-generic testing modules appeared on CPAN. Covering more
functionality, better maintained, arguably superior in pretty much every way
imaginable, they are kinda making 
the Dancer-specific module obsolete. 

Actually, scratch that "kinda". Typical of his usual soft-spoken
magnamity, Sawyer X declared that **DANCER2::TEST MUST DIE**, and as of the last
release of Dancer2, using it will trigger a warning and recommend you to use
[Test::Plack](cpan:module/Test::Plack) instead.

So, if not Dancer::Test and Dancer2::Test, what then? As mentioned above, 
the Dancer crew recommends [Plack::Test](cpan:Plack::Test). But there is also
[Test::TCP](cpan:Test::TCP) and 
[Test::WWW::Mechanize::PSGI](cpan::Test::WWW::Mechanize::PSGI). 

How do they compare? What is the proper way to make them play nice
with the Dancer app to test? Pretty good questions. To answer them, I
created the default boilerplate application for Dancer and Dancer2 (via
`dancer -a Test1` and `dancer2 -a Test2`), and implemented very simple tests
for each module. Let's see how it looks.

## [Dancer::Test](cpan:Dancer::Test) / [Dancer2::Test](cpan:Dancer2::Test) 

The testing modules that come bundled with Dancer itself. Pros: no need to
install any additional module. Cons: not as complete and sound as the other 
testing modules, and downright actively deprecated in the case of Dancer2.

### Dancer test
 
``` perl
use strict;
use warnings;

use Test::More tests => 3;

use Test1;
use Dancer::Test;

route_exists '/', 'a route handler is defined for /';

response_status_is '/', 200, 'response status is 200 for /';

response_content_like '/' => qr#&lt;title>Test1&lt;/title>#, 'title is okay';
```

### Dancer2 test


``` perl
use strict;
use warnings;

use Test::More tests => 3;

use Test2;

use Dancer2::Test apps => [ 'Test2' ];

{ package Test2; set log => 'error'; }

# to silence the deprecation notice
$Dancer2::Test::NO_WARN = 1;

route_exists [ GET =>  '/' ], 'a route handler is defined for /';

response_status_is '/', 200, 'response status is 200 for /';

response_content_like '/' => qr#&lt;title>Test2&lt;/title>#, 'title is okay';
```


## [Plack::Test](cpan:Plack::Test)

The testing module that comes with [Plack](cpan:release/Plack) itself.
Pros: it's the standard for PSGI application testing. Cons: it's also fairly
low-level.

### Dancer test

``` perl
use strict;
use warnings;

use Test::More tests => 3;

use Plack::Test;
use HTTP::Request::Common;

use Test1;
{ use Dancer ':tests'; set apphandler => 'PSGI'; set log => 'error'; }

test_psgi( Dancer::Handler->psgi_app, sub {
    my $app = shift;

    my $res = $app->( GET '/' );

    ok $res->is_success;

    is $res->code => 200, 'response status is 200 for /';

    like $res->content => qr#&lt;title>Test1&lt;/title>#, 'title is okay';
} );
```


### Dancer2 test

```perl
use strict;
use warnings;

use Test::More tests => 3;

use Plack::Test;
use HTTP::Request::Common;

use Test2;
{ package Test2; set apphandler => 'PSGI'; set log => 'error'; }

test_psgi( Test2::dance, sub {
    my $app = shift;

    my $res = $app->( GET '/' );

    ok $res->is_success;

    is $res->code => 200, 'response status is 200 for /';

    like $res->content => qr#&lt;title>Test2&lt;/title>#, 'title is okay';
} );
```

## [Test::TCP](cpan:release/Test-TCP)

This one doesn't only test the application using its PSGI interface, but 
really run the application on a local random port. Pros: you really test the
real, end-to-end deal. Cons: slightly slower, and can cause problems if your machine blocks some
ports.

### Dancer test

```perl
use strict;
use warnings;

use Test::More tests => 3;

use Test::TCP;
use Test::WWW::Mechanize;

Test::TCP::test_tcp( 
    client => sub {
        my $port = shift;

        my $mech = Test::WWW::Mechanize->new;

        $mech->get_ok( "http://localhost:$port/", 'a route handler is defined for /' );

        is $mech->status => 200, 'response status is 200 for /';

        $mech->title_is( 'Test1', 'title is okay' );

    },
    server => sub {
        use Test1;

        use Dancer ':tests';

        set port => shift;

        set log => 'error';

        Dancer->dance;
    }
);

```

### Dancer2 test

```perl
use strict;
use warnings;

use Test::More tests => 3;

use Test::TCP;
use Test::WWW::Mechanize;

Test::TCP::test_tcp( 
    client => sub {
        my $port = shift;

        my $mech = Test::WWW::Mechanize->new;

        $mech->get_ok( "http://localhost:$port/", 'a route handler is defined for /' );

        is $mech->status => 200, 'response status is 200 for /';

        $mech->title_is( 'Test2', 'title is okay' );

    },
    server => sub {
        use Test2;

        package Test2;

        Dancer2->runner->{port} = shift;

        set log => 'error';

        dance;
    }
);
```

## [Test::WWW::Mechanize::PSGI](cpan:release/Test-WWW-Mechanize-PSGI)

This one is my favorite. It's basically a wrapper that allows to
use [Test::WWW::Mechanize](cpan:release/Test-WWW-Mechanize-PSGI), itself
a wrapper with nifty test helper functions for
[WWW::Mechanize](cpan:release/WWW-Mechanize), on PSGI
applications. Also very nice: it
allows the tests to be trivially reused against a real server by having the `$mech`
object be a `Test::WWW::Mechanize` instead of a `Test::WWW::Mechanize::PSGI`.

### Dancer test

```perl
use strict;
use warnings;

use Test::More tests => 3;

use Test::WWW::Mechanize::PSGI;

use Test1;
{ use Dancer ':tests'; set apphandler => 'PSGI'; set log => 'error'; }


my $mech = Test::WWW::Mechanize::PSGI->new(
    app => Dancer::Handler->psgi_app
);

$mech->get_ok( '/', 'a route handler is defined for /' );

is $mech->status => 200, 'response status is 200 for /';

$mech->title_is( 'Test1', 'title is okay' );
```

### Dancer2 tests

```perl
use strict;
use warnings;

use Test::More tests => 3;

use Test::WWW::Mechanize::PSGI;

use Test2;
{ package Test2; set apphandler => 'PSGI'; set log => 'error'; }


my $mech = Test::WWW::Mechanize::PSGI->new(
    app => Test2::dance
);

$mech->get_ok( '/', 'a route handler is defined for /' );

is $mech->status => 200, 'response status is 200 for /';

$mech->title_is( 'Test2', 'title is okay' );
```
