#!/usr/bin/env perl

use strict;
use warnings;

package ModuleCounter::Mapper;

use Moose;
use Method::Signatures;

with 'Hadoop::Streaming::Mapper';

method map($line) {
    my ( $file, $creation, $content ) = split "\t", $line;

    # regex is not perfect, but for the example, it'll do
    $self->emit( $& => join " ", $creation, $file )
        while $content =~ /\w+(::\w+)+/g;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__->run;
1;

