#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use Getopt::Long;
use Git::Wrapper;
use List::Util qw/ sum /;
use Number::Bytes::Human qw/ format_bytes /;

my $delta;

GetOptions( 'delta=s' => \$delta );

my ( $tag, $path ) = @ARGV;

( my $server = $tag ) =~ s#/.*##;

my $git = Git::Wrapper->new('repos');

my %du;

for ( defined($delta) ? get_delta() : get_instance() ) {
    next unless s#^/?\Q$path\E/##;
    my ( $path, undef, undef, $size ) = split '\|';    
    my @path = split '/', $path;
    if ( $path =~ m#^(.+?)/# ) {
        $du{$1} += $size;
    }
    else {
        $du{'#files'} += $size;
    }
}

sub get_instance {
    return  $git->show( "$tag:$server" );
}

sub get_delta {
    # yes, only the additions. Because of the hard-links,
    # removals won't make a difference until the other
    # instances are removed as well
    return grep { s/^\+// } $git->diff( $delta, $tag );
}   

my $total = sum values %du;

for my $d ( sort { $du{$a} <=> $du{$b} } keys %du ) {
    my $percent = 100 * $du{$d} / $total;
    printf "%5.2f%\t%s\t%s\n",$percent, format_bytes($du{$d}), $d; 
}

say "---\ntotal size: ", format_bytes( $total );

