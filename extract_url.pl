#!/usr/bin/perl 

use strict;
use warnings;

use Regexp::Common qw/ URI /;
use WWW::Mechanize;
use Netscape::Bookmarks;
use Netscape::Bookmarks::Category;
use Netscape::Bookmarks::Link;

my $source = do { local $/ = <> };

$source =~ s/.*\n---\n//s;    # skip the preamble

my $bookmarks = Netscape::Bookmarks->new;
my $category =
  Netscape::Bookmarks::Category->new( { title => 'Shuck and Awe' } );
$bookmarks->add($category);
my $edition = Netscape::Bookmarks::Category->new(
    { title => 'Number 6 - June 16, 2010' } );
$category->add($edition);

my $mech = WWW::Mechanize->new;

for my $p ( split /\n{2,}/, $source ) {
    for my $url ( $p =~ /($RE{URI}{HTTP})/g ) {
        $url =~ s/\).*?$//;    # remove trailing trash
        eval { $mech->get($url) };

        if ( !$@ and $mech->success ) {
            $edition->add(
                Netscape::Bookmarks::Link->new( {
                        HREF        => $url,
                        TITLE       => $mech->title,
                        DESCRIPTION => $p,
                    } ) );
        }
        else {
            warn "$url doesn't seem to be valid\n";
        }

    }
}

print $bookmarks->as_string;

