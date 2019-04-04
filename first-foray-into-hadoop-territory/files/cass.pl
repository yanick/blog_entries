#!/usr/bin/env perl 

use strict;
use warnings;

use Cassandra::Lite;

my $c = Cassandra::Lite->new(keyspace => 'galuga');

$c->put( 'blog_entries' => 'hadoop' => {
    title  => 'First Foray in Hadoop territory',
    body   => '...',
} );

# .. then, later on

my $entry = $c->get('blog_entries' => 'hadoop' );

