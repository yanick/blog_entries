#!/usr/bin/perl 

use 5.20.0;

use warnings;

package Person {
    use Moose;

    use Moose::Util qw/ with_traits /;
    use MooseX::ClassAttribute;

    use experimental 'signatures';

    class_has default_age_formatter => (
        is => 'ro',
        default => 'Spell',
    );

    has age_formatter => (
        is      => 'ro',
        default => sub($self){ $self->default_age_formatter }
    );

    sub new($class,@args) {
        my %args = @args == 1 ? %{ shift @args } : @args;

        with_traits(
            $class,
            'Person::FormatAge::' .(  $args{age_formatter} ||= $class->default_age_formatter )
        )->SUPER::new(
            %args
        );
    }

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}

package Person::FormatAge {

    use Moose::Role;

    requires 'formatted_age';

}

package Person::FormatAge::Spell {

    use Moose::Role;

    use Number::Spell;

    use experimental 'signatures';

    with 'Person::FormatAge';

    sub formatted_age($self) {
        spell_number( $self->age );
    }
}

package Person::FormatAge::Relative {

    use Moose::Role;

    use experimental 'signatures';

    with 'Person::FormatAge';

    has relative_to => (
        is => 'ro',
        isa => 'Int',
        required => 1,
    );

    sub formatted_age ($self) {
        $self->age < $self->relative_to ? 'younger' : 'older'
    }
}

# print 'forty one'
say Person->new( 
    age => 41
)->formatted_age;

# prints 'older'
say Person->new( 
    age_formatter => 'Relative',
    age => 41, 
    relative_to => 50 
)->formatted_age;
