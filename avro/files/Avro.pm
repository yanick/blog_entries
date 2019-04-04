package Class::Avro;

use strict;
use warnings;

use Moose;

use Class::Avro::Role;

use Method::Signatures;

use Moose::Util::TypeConstraints;

subtype AvroSchema => as 'HashRef';
coerce  AvroSchema => from 'Str' => via { from_json $_ };

has schema => (
    is => 'ro',
    isa => 'AvroSchema',
    required => 1,
    coerce => 1,
);

has class => (
    is => 'ro',
    lazy => 1,
    builder => '_build_class',
    handles => [qw/ new_object /], 
);

method _build_class {
    my $schema = $self->schema;

    # Moose::Meta::Class->create( $schema->{name} ) 
    # doesn't do what I want, it seems. :-/
    eval "package $schema->{name}; use Moose;";

    my $class = $schema->{name}->meta;

    Class::Avro::Role->meta->apply($class);

    for my $field ( @{ $schema->{fields} } ) {
        my %arg = ( accessor => $field->{name} );

        if ( my $type = $Class::Avro::Role::AVRO2MOOSE_TYPEMAP{$field->{type}} ) {
            $arg{isa} = $type;
        }   

        $class->add_attribute( $field->{name} => %arg );
    }

    return $class;
}

method deserialize($json) { $self->class->name->thaw($json); }

method avro_schema { $self->class->name->avro_schema; }

1;
