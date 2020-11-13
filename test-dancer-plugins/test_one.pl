#!/usr/bin/perl 

use 5.14.0;

use DancerTest;
use DancerTest::Model::Plugin;

my $store = DancerTest->connect( 'plugins.db' );

$store->register;

while( my $module = <> ) {
    chomp $module;
    next if $module=~ /^\s*#/;
    $store->new_model_object('Plugin',
        name => $module,
        verbose => 1,
    )->store;
}

