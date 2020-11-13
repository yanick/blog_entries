#!/usr/bin/env perl

use 5.24.0;
use strict;
use warnings;

use YAML;
use Path::Tiny;
use Path::Tiny::Glob;
use JSON qw/ to_json /;
use List::UtilsBy qw/ sort_by /;

my @readmes = pathglob([shift, '*', 'README.md' ])->all;

my @data = reverse sort_by { $_->{created} }  map { file2data($_) } @readmes;

print to_json( \@data, {pretty => 1, canonical => 1} );

sub file2data {
    my $file = path(shift);

    my( undef, $meta, $content ) = split /---/, $file->slurp;

    my $data = YAML::Load($meta);
    $data->{slug} = "/".$file->parent->basename;

    return $data;
}

