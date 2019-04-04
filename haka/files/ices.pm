# source abridged for blog entry, 
# see GitHub repo for the whole thing

use strict;
use warnings;

use autodie;
use Path::Class;

our $collection_dir = dir( $ENV{COLLECTION} )
    or die 'environment variable COLLECTION not set';

our $playlist_dir = dir( $ENV{PLAYLIST} )
    or die 'environment variable PLAYLIST not set';

sub ices_get_next {
	print "Perl subsystem quering for new track:\n";

    if ( my ( $song ) = sort $playlist_dir->children ) {
        print "playlist is present";
        my $file = file( $song )->slurp( chomp => 1 );
        unlink $song;
        return $file;
    }

    print "playlist empty, get one from the collection";
    my @files = grep { /\.mp3$/ } $collection_dir->children;
    return $files[ rand @files ];
}

