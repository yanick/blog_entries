#!/usr/bin/env perl

use strict;
use warnings;

use Pod::Find qw/ pod_where /;
use Pod::XML;
use XML::LibXML;

my $module = shift or die "usage: $0 <module>\n";

my $xml = do {
    local *STDOUT;
    open STDOUT, '>', \my $stdout; 
    Pod::XML->new->parse_from_file( pod_where( { -inc => 1 }, $module ) );
    $stdout;
};

$xml =~ s/xmlns=".*?"//;

print XML::LibXML->load_xml( string => $xml )
        ->findvalue('//sect1[title/text()="SYNOPSIS"]/verbatim');
