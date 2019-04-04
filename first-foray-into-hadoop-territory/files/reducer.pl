#!/usr/bin/env perl

package Modulecounter::Reducer;

use Moose;
use Method::Signatures;

with 'Hadoop::Streaming::Reducer';

method reduce($key, $it) {
    my( $oldest_time, $file ) = ( 0, '' );

    while( $it->has_next ) {
        my @e = split ' ', $it->next;
        ($oldest_time, $file) = @e if $e[0] > $oldest_time;
    }

    $self->emit( $key => "$file ($oldest_time)" );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__->run;
1;
