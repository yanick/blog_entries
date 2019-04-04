#!/usr/bin/perl 

use strict;
use warnings;

use Netscape::Bookmarks;

my $bookmarks = Netscape::Bookmarks->new(shift);

my @links = extract_links($bookmarks);

print join " ", @links;

sub extract_links {
    return map {
        ref eq 'Netscape::Bookmarks::Category'
          ? extract_links( @{ $_->{thingys} } )
          : $_
    } @_;
}

