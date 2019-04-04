---
---

# Suddenly, roles!


In most sane worlds, 
Moose roles are statically assigned to classes.
But sometimes it's useful to take a stroll at the edge of sanity and assign
them at build time.

For example, let's suppose we have the following class `Person`

```perl
package Person {
    use Moose;

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}
```

and we want to have a method `formatted_age` that pretty print
the age. The gotcha is that we want to have the choice between
different pretty printings. To give us the alternative via roles is not hard:

```perl

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

package Person::Format::Relative {

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
```

Now, how to connect the dots between the class and the roles?

## The sensible way: MooseX::Traits

As one might suspect, there is already a Moose module to apply
roles at build time: [MooseX-Traits](cpan:releases/MooseX-Traits). 
It provides a class method `with_traits` that create a new 
anonymous class that is the original class augmented with the 
given roles.

```
package Person {
    use Moose;

    with 'MooseX::Traits';

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}

# roles stay the same as before

# prints 'forty one'
say Person->with_traits('Person::FormatAge::Spell')
        ->new( age => 41 )
        ->formatted_age;

# prints 'younger'
say Person->with_traits('Person::FormatAge::Relative')
    ->new( age => 41, relative_to => 50 )
    ->formatted_age;

```

## Still reasonable, with default

Now, let's say we want `Spell` to be the default. We could do that by wrapping
`with_traits` in a custom class method:

```
package Person {
    use Moose;

    with 'MooseX::Traits';

    use experimental 'signatures';

    has age => (
        isa => 'Int',
        is  => 'ro',
    );

    sub with_age_formatter($class,$formatter='Spell') {
        $class->with_traits( 'Person::FormatAge::'.$formatter );
    }
}

# roles stay the same as before

# prints 'forty one'
say Person->with_age_formatter
        ->new( age => 41 )
        ->formatted_age;

# prints 'younger'
say Person->with_age_formatter('Relative')
    ->new( age => 41, relative_to => 50 )
    ->formatted_age;
```

## Getting slightly mad with the power

The previous solution is pretty neat. It's also clean, and we should probably
leave it at that.

We should. But we won't. What if we want to merge the role injestion within
`new`? How can we do that?

At first, I thought it would be as simple as 

```
package Person {
    use Moose;

    use Moose::Util qw/ apply_all_roles /;

    use experimental 'signatures';

    has age_formatter => (
        is      => 'ro',
        default => 'Spell',
    );

    sub BUILD($self,@rest) {
        apply_all_roles( $self, 'Person::FormatAge::'.$self->age_formatter )
    }

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}

# roles stay the same

# print 'forty one'
say Person->new( 
    age => 41
)->formatted_age;

# goes BOOM!
say Person->new( 
    age_formatter => 'Relative',
    age           => 41,
    relative_to   => 50
)->formatted_age;
```

Ooops. Doesn't work. That's because by the time we hit `BUILD`, we already
processed our arguments and so the `Relative` role doesn't have the change to
get the value for `relative_to`.

## Going full-on, no-seatbelt batshit insane

So we need to alter the class before we reach `BUILD`. We don't have a lot of
point of entries for that. There is `BUILDARGS`, but then it only allows to
munge arguments, not the class. Right?

Ah! Wrong!

```
package Person {
    use Moose;

    use Moose::Util qw/ with_traits /;
    use MooseX::ClassAttribute;

    use experimental 'signatures';

    class_has default_age_formatter => (
        is      => 'ro',
        default => 'Spell',
    );

    has age_formatter => (
        is      => 'ro',
        default => sub($self){ $self->default_age_formatter }
    );

    sub BUILDARGS($class,@args) {
        my %args = @args == 1 ? %{ shift @args } : @args;

        # needs to be $_[0] so that we alter
        # the referenced value
        $_[0] =~ s/.*/
            with_traits(
                $class,
                'Person::FormatAge::' .(  $args{age_formatter} ||= $class->default_age_formatter )
            )
        /e;

        return \%args;
    }

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}


# roles stay the same

# print 'forty one'
say Person->new( 
    age => 41
)->formatted_age;

# prints 'younger'
say Person->new( 
    age_formatter => 'Relative',
    age           => 41,
    relative_to   => 50
)->formatted_age;
```

## Dialing down the crazy a wee bit

Using references passed as `@_` to switch the class right from
within the Moose object creation process is... let's just call it
"thinking outside the padded box". For real-world usage, it's most
definitively to tone down the cleverness, and implement the 
same logic in `new` instead:

```perl
package Person {
    use Moose;

    use Moose::Util qw/ with_traits /;
    use MooseX::ClassAttribute;

    use experimental 'signatures';

    class_has default_age_formatter => (
        is      => 'ro',
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
        )->SUPER::new(%args);
    }

    has age => (
        isa => 'Int',
        is  => 'ro',
    );
}

# roles stay the same

# print 'forty one'
say Person->new( 
    age => 41
)->formatted_age;

# prints 'younger'
say Person->new( 
    age_formatter => 'Relative',
    age           => 41, 
    relative_to   => 50 
)->formatted_age;
```
