#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use LWP::Simple;

my $uid      = '3196';
my $username = 'Yanick';

my $main = get( 'http://use.perl.org/journal.pl?op=list&uid=' . $uid );

while ( my ($entry_id) =
    $main =~ m#//use.perl.org/~$username/journal/(\d+)#g ) {

    say "retrieving $entry_id...";

    getstore( "http://use.perl.org/~$username/journal/$entry_id", $entry_id );

    sleep 1;    # let's be nice to the server, shall we?
}

