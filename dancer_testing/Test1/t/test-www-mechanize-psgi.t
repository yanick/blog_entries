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
