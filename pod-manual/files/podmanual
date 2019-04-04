#!/usr/bin/env perl

use Getopt::Long;

GetOptions(
    'formatter=s' => \my $formatters,
    'as=s'        => \my $format,
    'output=s'    => \my $output_file,
);

my $source = shift;

my $manual;

if ( -e $source ) {
    $manual = do $source;
}
else {
    eval "use $source;";
    die $@ if $@;

    $manual = $source->master;
}

for my $f ( split ',', $formatters ) {
    my $fclass = "Pod::Manual::Formatter::$f";
    eval "use $fclass;";
    die $@ if $@;

    $fclass->meta->apply( $manual );
}

my $method = 'save_as_' . $format;

print "creating $output_file...\n";

$manual->$method( filename => $output_file );

print "done\n";
