---
title: Dancer In Chains
url: dancer-in-chains
format: markdown
created: 8 Feb 2014
tags:
    - Perl
    - Dancer
---

Sometimes, you idly think about a problem and an answer comes to you.
And it has the simplicity and the elegance of a shodō brush-stroke. It
is so exquisitely perfect, you have to wonder... Have you reached the
next level of enlightenment, or did the part of your brain 
responsible for discernment suddenly called it quit?

I'll let you be judge of it.

## Chains of Command

Something that [Catalyst](http://catalystframework.org) has and 
[Dancer](http://perldancer.org) doesn't is chained routes. A little while ago, 
I came up with a way to mimic chains [using megasplats](blog:chained-dancer).
People agreed: it was cute, but not quite de par with Catalyst's offering.

Which brings us to my epiphany of yesterday...

## Forging the Links

What if we did things just a tad different than what Catalyst does?
What if the bits making the chain segments were defined outside of routes:

``` perl
my $country = chain '/country/:country' => sub {
    # silly example. Typically much more work would 
    # go on in here
    var 'site' => param('country');
};

my $event = chain '/event/:event' => sub {
    var 'event' => param('event');
};
```

And what if we could put them together as we define the final routes:

``` perl
# will match /country/usa/event/yapc
get chain $country, $event, '/schedule' => sub {
    return sprintf "schedule of %s in %s\n", map { var $_ } qw/ site event/;
};
```

Or we could forge some of those segments together as in-between steps too:

```perl
my $continent = chain '/continent/:continent' => sub {
    var 'site' => param('continent');
};

my $continent_event = chain $continent, $event;

# will match /continent/europe/event/yapc
get chain $continent_event, '/schedule' => sub {
    return sprintf "schedule of %s in %s\n", map { var $_ } qw/ event site /;
};
```

Or, heck, we could even insert special in-situ operations directly in the
route when the interaction between two already-defined segments needs a
little bit of fudging:

```perl
# will match /continent/asia/country/japan/event/yapc
# and will do special munging in-between!

get chain $continent, 
          sub { var temp => var 'site' },
          $country, 
          sub {
              var 'site' => join ', ', map { var $_ } qw/ site temp /
          },
          $event, 
          '/schedule' 
            => sub {
                return sprintf "schedule of %s in %s\n", map { var $_ } 
                               qw/ event site /;
          };
```

Wouldn't that be something nice?

## The Wind of Chains...ge

Here's the shocker: all the code above is functional. Here's the
double-shocker: the code required to make it happen is ridiculously
short.

First, I had to create a class that represents chain bits. The objects are
simple things keeping track of the pieces of path and code chunks constituting 
the segment.

```perl
package Chain;

use Moose;

has "path_segments" => (
    traits => [ qw/ Array /],
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
    handles => {
        add_to_path       => 'push',
        all_path_segments => 'elements'
    },
);

sub path {
    my $self = shift;
    return join '', $self->all_path_segments;
}

has code_blocks => (
    traits => [ qw/ Array /],
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
    handles => {
        add_to_code     => 'push',
        all_code_blocks => 'elements'
    },
);

sub code {
    my $self = shift;

    my @code = $self->all_code_blocks;
    return sub {
        my $result;
        $result = $_->(@_) for @code;
        return $result;
    }
}

sub BUILD {
    my $self = shift;
    my @args = @{ $_[0]{args} };

    my $code;
    $code = pop @args if ref $args[-1] eq 'CODE';

    for my $segment ( @args ) {
        if ( ref $segment eq 'Chain' ) {
            $self->add_to_path( $segment->all_path_segments );
            $self->add_to_code( $segment->all_code_blocks );
        }
        elsif( ref $segment eq 'CODE' ) {
            $self->add_to_code($segment);
        } 
        else {
            $self->add_to_path( $segment );
        }
    }

    $self->add_to_code($code) if $code;
}

sub as_route {
    my $self = shift;

    return ( $self->path, $self->code );
}
```
Then, I had to write the `chain()` DSL keyword making the junction
between the objects and the Dancer world:

```perl
sub chain(@) {
    my $chain = Chain->new( args => [ @_ ] );

    return wantarray ? $chain->as_route : $chain;
}
```

And then... well, then, I was done.

## What Happens Next

Obviously, there will be corner cases to consider. For example, 
the current code doesn't deal with regex-based paths, and
totally ignore prefixes. But I have the feeling it could go somewhere...

So, yeah, that's something that should make it to CPAN relatively soon. 
Stay tuned!
