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

    like $res->content => qr#<title>Test1</title>#, 'title is okay';
} );

