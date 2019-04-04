#!/usr/bin/env perl

# usage: du_gather_history.pl gilgamesh 1 2 3 4 5

use 5.10.0;

use strict;
use warnings;

use autodie;
use Git::Wrapper;

# yup, that's why I used 'caller' there
require 'du_gather.pl';
chdir 'dudb';
my $git = Git::Wrapper->new('.');

my $server = shift;

for ( @ARGV ) {
    my $week = sprintf "%02d", $_;

    say "processing $server/$week";

    $git->checkout( $server );

    open my $fh, '>', $server;

    rsync_gather( $server, $week, $fh );

    $git->add( $server );

    my $tag = "$server/$week";
    $git->commit( { message => $tag } );
    $git->tag( { force => 1 }, $tag );
}
