use strict;
use warnings;

use Test::More;

use Test::WWW::Mechanize;

my %links = (
    'http://babyl.dyndns.org'          => 'nAB-zONE',
    'http://babyl.dyndns.org/techblog' => 'Hacking Thy Fearful Symmetry',
    'http://kontext.ca'                => 'Kontext.ca',
    'http://academiedeschasseursdeprimes.ca' =>
      "Acad\x{e9}mie des chasseurs de prime",
    'http://michel-lacombe.dyndns.org' => 'Michel Lacombe, cartoonist',
);

plan tests => 2 * keys %links;

my $mech = Test::WWW::Mechanize->new;

while ( my ( $url, $title ) = each %links ) {
    $mech->get_ok($url);
    $mech->title_is( $title, "title of $url" );
}

