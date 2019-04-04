use strict;
use warnings;

use Test::More tests => 3;

use Test2;
use Dancer2::Test apps => [ 'Test2' ];

{ package Test2; set log => 'error'; }

$Dancer2::Test::NO_WARN = 1;

route_exists [ GET =>  '/' ], 'a route handler is defined for /';

response_status_is '/', 200, 'response status is 200 for /';

response_content_like '/' => qr#<title>Test2</title>#, 'title is okay';
