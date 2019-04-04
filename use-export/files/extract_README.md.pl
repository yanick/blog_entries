---
#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use pQuery;
use utf8;    #unless you want xml, you can skip utf8'ing the output

$/ = undef;  # it's slurping time

my $p = pQuery(<>);

say "title: ", $p->find('.title h3')->get(1)->innerHTML;

my ( $month, $day, $year ) =
  $p->find('.journaldate')->html() =~ /(\w{3})\w* 0?(\d+), (\d{4})$/;
say "date: ", "$day $month $year";

say "original url: http:"
  . $p->find('.h-inline a')->get(0)->getAttribute('href');

say "\n";

utf8::encode( my $entry = $p->find('.intro')->get(0)->innerHTML );

say $entry;

