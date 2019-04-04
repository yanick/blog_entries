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
