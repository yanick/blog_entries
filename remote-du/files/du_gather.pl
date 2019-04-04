#!/usr/bin/env perl 

use 5.10.0;

use strict;
use warnings;

use File::RsyncP;

my $backup_server = "ninsun";

rsync_gather(@ARGV) unless caller;

sub rsync_gather {
    my ( $machine, $week, $fh ) = @_;

    # outputs to STDOUT unless specified otherwise
    open $fh, '>', '-' unless $fh;

    my $rs = File::RsyncP->new( {
            logLevel  => 0,
            rsyncArgs => [
                '--relative',
                '--recursive',
                '--block-size=700',
                '--links',
                '--hard-links',
            ],
        } );

    $rs->serverConnect( $backup_server );

    # rsync credentials
    $rs->serverService( $machine, $username, $password );

    $rs->serverStart( 1, "/$week" );

    # following logic borrowed from File::RsyncP's guts

    my $remoteDir = $rs->{remoteDir};
    return $rs->{fatalErrorMsg} if ( $rs->getData(4) < 0 );
    $rs->{checksumSeed} = unpack( "V", $rs->{readData} );
    $rs->{readData} = substr( $rs->{readData}, 4 );
    $rs->{fio}->checksumSeed( $rs->{checksumSeed} );

    $rs->log( sprintf( "Got checksumSeed 0x%x", $rs->{checksumSeed} ) )
      if ( $rs->{logLevel} >= 2 );

    $rs->fileListReceive;

    # tada! we have our file listing

    my $fl = $rs->{fileList};

    for ( 0 .. $fl->count - 1 ) {
        my %data = %{ $fl->get($_) };

        next unless $data{size};

        my $s = join '|', @data{qw/ name inode mtime size/};
        $s =~ s#^/\d+##;

        # prints "$directory/$filename|$inode|$mtime|$size\n"
        say {$fh} $s;
    }

}
