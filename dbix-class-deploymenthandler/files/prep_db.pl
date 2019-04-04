#!/usr/bin/env perl

use 5.12.0;

use strict;
use warnings;

use lib 'lib';

use DBIx::Class::DeploymentHandler;
use SQL::Translator;

my $schema = 'cpanvote::Schema';
#my $schema = 'MyDB::Schema';

my $version = eval "use $schema; $schema->VERSION" or die $@;

say "processing version $version of $schema...";

my $s = $schema->connect('dbi:SQLite:mydb.sql');

my $dh = DBIx::Class::DeploymentHandler->new( {
        schema              => $s,
        databases           => [qw/ SQLite PostgreSQL MySQL /],
        sql_translator_args => { add_drop_table => 0, },
    } );

say "generating deployment script";
$dh->prepare_install;

if ( $version > 1 ) {
    say "generating upgrade script";
    $dh->prepare_upgrade( {
            from_version => $version - 1,
            to_version   => $version,
            version_set  => [ $version - 1, $version ],
        } );

    say "generating downgrade script";
    $dh->prepare_downgrade( {
            from_version => $version,
            to_version   => $version - 1,
            version_set  => [ $version, $version - 1 ],
        } );
}

say "generating graph";

my $trans = SQL::Translator->new(
    parser        => 'SQL::Translator::Parser::DBIx::Class',
    parser_args   => { package => $schema },
    producer      => 'Diagram',
    producer_args => {
        out_file         => 'sql/diagram-v' . $version . '.png',
        show_constraints => 1,
        show_datatypes   => 1,
        show_sizes       => 1,
        show_fk_only     => 0,
    } );

$trans->translate;

say "done";

