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

