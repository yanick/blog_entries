package Class::Avro::Role;

use 5.14.0;

use strict;
use warnings;

use Moose::Role;

use MooseX::Storage;

use Method::Signatures;
use JSON qw/ from_json to_json /;

with Storage( format => 'JSON' );

our %AVRO2MOOSE_TYPEMAP = (
    string  => 'Str',
    boolean => 'Bool',
    int     => 'Int',
);

our %MOOSE2AVRO_TYPEMAP = reverse %AVRO2MOOSE_TYPEMAP;

method avro_schema {
    my $class = $self->meta;

    my %schema;

    $schema{type} = 'record';
    $schema{name} = $class->name;

    $schema{fields} = [];

    for my $attr ( grep { 
            not $_->does( 
                'MooseX::Storage::Meta::Attribute::Trait::DoNotSerialize' 
            ) 
        } $class->get_all_attributes ) {

        push $schema{fields} => {
            name => $attr->name,
            ( type => $MOOSE2AVRO_TYPEMAP{$attr->type_constraint} ) 
                x $attr->has_type_constraint
        };
    }

    return to_json \%schema;
}

method serialize { $self->freeze }

1;
