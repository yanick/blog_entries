---
created: 2018-01-27
tags:
    - perl
    - moose
---

# One builder to rule them all

I've just punted
[MooseX-Attribute-Multibuilder](cpan:MooseX-Attribute-Multibuilder) to
CPAN. It's a dirt-simple module, but it addresses a itch I had since forever.

## The fun of related attributes

I'm sure you had that problem a few times as well. You have this object with 
a few attributes, and the generation of their default values happens to be
interconnected. For example, let's say you have an object pointing to a web
page and recording its title and creation time. Naively, you can do something
like this:

```perl

package MyPage;

use Moose;

use Web::MadeUp::Magic::Module qw/ fetch /;

use experimental 'signatures';

has url => (
    is       => 'ro',
    required => 1,
);

has title => (
    is   => 'ro',
    lazy => 1,
    default => sub($self) {
        fetch( $self->url )->h1;
    },
);

has creation_time => (
    is   => 'ro',
    lazy => 1,
    default => sub($self) {
        fetch( $self->url )->creation_time;
    },
);

```

It works, but we're hitting the url twice. Feels wasteful.

## The solution, traditionally

The usual way around that is to have an intermediary private attribute
holding the required data. Something like:


```perl

package MyPage;

use Moose;

use Web::MadeUp::Magic::Module qw/ fetch /;

use experimental 'signatures';

has url => (
    is       => 'ro',
    required => 1,
);

has _page => (
    is      => 'ro',
    lazy    => 1,
    default => sub($self) {
        fetch( $self->url )
    }
);

has title => (
    is      => 'ro',
    lazy    => 1,
    default => sub($self) {
        $self->_page->h1;
    },
);

has creation_time => (
    is   => 'ro',
    lazy => 1,
    default => sub($self) {
        $self->_page->creation_time;
    },
);

```

Or even, if `page` turns out to be too big to keep around:


```perl

package MyPage;

use Moose;

use Web::MadeUp::Magic::Module qw/ fetch /;

use experimental 'signatures';

has url => (
    is       => 'ro',
    required => 1,
);

has _page_info => (
    is      => 'ro',
    lazy    => 1,
    default => sub($self) {
        return {
            map {
                title         => $_->h1,
                creation_time => $_->creation_time,
            } fetch( $self->url )
        }
    }
);

has title => (
    is      => 'ro',
    lazy    => 1,
    default => sub($self) {
        $self->_page_info->{title};
    },
);

has creation_time => (
    is   => 'ro',
    lazy => 1,
    default => sub($self) {
        $self->_page_info->{creation_time};
    },
);

```

## The multibuilder solution

The solutions from the previous section are fine, but they still 
require to set up that in-between attribute. That's more work than 
strictly necessary. Which is where the new attribute trait enters the
picture. It introduces a new attribute option, `multibuilder`, that
act just like builder, but instead of returning the value for a single
attribute, it's expected to return a set of default values. In other words,
the management of the intermediary state is taken care of for us.

As usual, an example would speak much eloquently than anything else:


```perl

package MyPage;

use Moose;
use MooseX::Attribute::Multibuilder;

use Web::MadeUp::Magic::Module qw/ fetch /;

use experimental 'signatures';

has url => (
    is       => 'ro',
    required => 1,
);

has [qw/ title creation_time /] => (
    traits       => [ 'Multibuilder' ],
    is           => 'ro',
    lazy         => 1,
    multibuilder => '_page_info',
);

sub _page_info($self) {
    return {
        map {
            title         => $_->h1,
            creation_time => $_->creation_time,
        } fetch( $self->url )
    }
}

```

Is it a huge change? Not really. But it's greasing a wheel
that has been squeaking for me for a long time, and it's worth it.

Enjoy!

