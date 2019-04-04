#!/usr/bin/env perl 

use 5.10.0;

use strict;
use warnings;

use File::Find::Rule;
use Path::Class qw/ file /;

File::Find::Rule
    ->file()
    ->name( 'entry', '*.pl', '*.pm' )
    ->exec( sub {
        my $file = $_[2];
        print join "\t", $file, -M $file, $_ 
            for file($file)->slurp;
    } )
    ->in( '/home/yanick/work/blog_entries' );

