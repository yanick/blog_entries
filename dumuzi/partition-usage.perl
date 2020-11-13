use 5.10.0;

use strict;
use warnings;

use Test::More tests => 5;                      # last test to print
use Dumuzi;

use Sys::Statistics::Linux::DiskUsage;

my $lxs  = Sys::Statistics::Linux::DiskUsage->new;
my $stat = $lxs->get;

my $worry_percent = 80;
my $panic_percent = 90;

while( my ( $partition, $stats ) = each %$stat ) {
    check_partition( $partition, $stats );
}


sub check_partition {
    my $partition = shift;
    my %stats = %{ shift( @_ ) };

    my $result = $stats{usageper} < $worry_percent ? $OK
               : $stats{usageper} < $panic_percent ? $WORRY
               :                                     $PANIC
               ;

    check "partition $partition", $result, explain \%stats;
}

