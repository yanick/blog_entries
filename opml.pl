#!/usr/bin/perl 

use strict;
use warnings;

use XML::OPML::SimpleGen;

my $opml = XML::OPML::SimpleGen->new;

$opml->head(
    title => 'Shuck and Awe #7',
);

$opml->insert_outline(
    group => 'Shuck and Awe #7',
    text => 'yadah',

);



