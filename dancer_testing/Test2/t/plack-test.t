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

    like $res->content => qr#<title>Test2</title>#, 'title is okay';
} );

