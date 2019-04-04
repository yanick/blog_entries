package Dumuzi;

use 5.10.0;

use strict;
use warnings;

use parent qw/ Test::Builder::Module Exporter/;

our ( $OK, $WORRY, $PANIC ) = 0..2;

our @EXPORT = qw/ $OK $WORRY $PANIC &check /;

our $TODO;

sub check($$@) {
    my ( $title, $result, @diag ) = @_;

    my $tb = __PACKAGE__->builder;

    given ( $result ) {
        when ( $OK ) {
            $tb->ok( 1, $title );
        }
        when ( $WORRY ) {
            local $TODO = "test has crossed the worrying line";
            $tb->ok( 0, $title );
        }
        when ( $PANIC ) {
            $tb->ok( 0, $title );
        }
    }

    $tb->diag( @diag );
}

1;
