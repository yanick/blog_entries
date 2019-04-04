use strict;
use warnings;

use Test::More tests => 3;

use Test1;
use Dancer::Test;

route_exists '/', 'a route handler is defined for /';

response_status_is '/', 200, 'response status is 200 for /';

response_content_like '/' => qr#<title>Test1</title>#, 'title is okay';
