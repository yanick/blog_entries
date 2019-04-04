---
url: shaving-the-white-whale
format: markdown
created: 22 jun 2012
tags:
    - Perl
    - MooseX::Storage
    - DBIx::NoSQL
---

# Shaving the White Whale (DBIx::NoSQL + MooseX::Storage)

I'm a lazy bum.

Don't take my word for it. Let me bring forward the undenialable evidences.

So I'm working on the rewrite of [Galuga](http://babyl.dyndns.org/techblog/entry/galuga) 
which, just like the phoenix, is
destined to be reborn amidst a spectacular corona of flames. Or, considering that we're
talking about a gamboling beluga here, maybe more of a big watery splash.  Or 
something like that. Anyway, the point is: I'm working on its core, which
consist mostly of the data model used to store and access the blog entries.

I am still very much in love with using a Git repository as the base storage
mechanism (an idea which seed comes from Angerwhale, incidentally). But a Git
repository isn't perfect to sort entries or filter them by tags or to perform
semi-sophisticated queries on the blog opus (hmmm... blogopus... rather sound
like the Internet-savvy cousin of the platypus, doesn't it?). That problem was
solved in the first iteration of Galuga by using an SQLite database as an 
in-between model. The idea wasn't too bad and served me well. The crafting
of new blog entries was a breeze, and once the `DBIx::Class` schema was in
place, the interface between the base Git repository and the "working stage"
SQLite database was automatic.

But... (that sound? You're correct, that's indeed a herd of yaks sneakily
tip-toeing toward us) But... isn't a little overkill to model the full blog 
entry attributes as database columns?  After all, I just want to have a
serialized version of my objects ready for the taking, with only a small
subset of its attributes indexed for impromptu sorting, filtering and all that
jazz.

That, I thought to myself, sounds a lot like a job for your typical NoSQL
engine. Let's try it.

And with that thought flying in my mind like a crusader's banner, 
I embarked on a weeks-long journey of discoveries to save myself the 
pain of defining one database schema...

Along the way, I played with Mongo and looked at [Mongoose](cpan), which
are nifty but... holy schmolee are mongo databases huge. And then I
re-discovered [DBIx::NoSQL](cpan), which was pretty much smack what I
wanted.  But I needed a way to easily serialize my objects for it. So I
dragged in [MooseX::Storage](cpan) to the mix.  And then I had fun with
helper classes and roles to make the interfacing between the two systems as 
smooth and slick as a buttered piglet.  

## But does it blend?

To drive-test the resulting hydrid, I simplified Galuga's model to
blog entries having only an uri, a creation date and a bunch of tags,
with the requirement that I want to access them via their 'uri', and do
funky searches on tags.  To do all of that, here's the classes I need to set
up.

First, I need a store manager (think [DBIx::Class::Schema](cpan)-like
mothership):


    #syntax: perl
    package Galuga::Store;

    use Moose;

    use Method::Signatures;

    extends 'DBIx::NoSQL::Store::Manager';

    method all_tags {
        # throw the gloves off and just go down and dirty with raw SQL
        return sort $self->schema->resultset('EntryTag')
                        ->search({},{ columns => 'tag', distinct => 1 })
                        ->get_column('tag')->all;
    }

    __PACKAGE__->meta->make_immutable(inline_constructor => 0);

    1;

(*shhhh* yes, I'll explain the magic later on. For now, just let the joy of
minimalism sink in)

And then comes the beefiest class: the model for the blog entries:


    #syntax: perl
    package Galuga::Store::Model::Entry;

    use Moose;

    use Method::Signatures;
    use Galuga::Store::Types qw/ URIClass DateTimeClass SetClass /;

    with 'DBIx::NoSQL::Store::Model::Role';

    has uri => (
        traits => [ 'StoreKey' ],
        isa    => 'URIClass',
        is     => 'rw',
        coerce => 1,
    );

    has date_created => (
        traits  => [ 'StoreIndex' ],
        isa     => 'DateTimeClass',
        is      => 'rw',
        default => sub { DateTime->now },
    );

    has tags => (
        is      => 'rw',
        isa     => 'SetClass',
        handles => {
            add_tags => 'insert',
            remove_tags => 'remove',
            _all_tags => 'elements',
        },
        coerce => 1,
    );

    # update the related tags when we store the entry
    after store => sub {
        my $self = shift;

        # play it safe: remove all first
        $_->delete for $self->store_db->model('EntryTag')->search({
            entry_key => $self->store_key 
        })->all;

        $self->store_db->new_model_object( 'EntryTag', 
            entry_key => $self->store_key,
            tag       => $_,
        )->store for $self->all_tags;
    };

    method all_tags { sort $self->_all_tags } 

    __PACKAGE__->meta->make_immutable;

    1;

last bit: the model that capture the relationship between the entries and the
tags.


    #syntax: perl
    package Galuga::Store::Model::EntryTag;

    use Method::Signatures;

    use Moose;
    use Galuga::Store::Types qw/ URIClass DateTimeClass SetClass /;

    with 'DBIx::NoSQL::Store::Model::Role';

    has '+store_key' => (
        default => method {
            join ' : ', $self->entry_key, $self->tag;
        },
    );

    has entry_key => (
        traits => [ 'StoreIndex' ],
        isa => 'URIClass',
        is => 'rw',
        coerce => 1,
    );

    has tag => (
        traits => [ 'StoreIndex' ],
        is => 'rw',
        isa => 'Str',
    );

    method entry { $self->store_db->get( 'Entry' => $self->entry_key ) }

    __PACKAGE__->meta->make_immutable;

    1;


With that, our store is ready. And how do we use it? Like this:


    #syntax: perl

    use 5.10.0;

    use strict;
    use warnings;

    use Galuga::Store;

    my $store = Galuga::Store->connect( 'foo.db' );

    $store->register;  # create all the indexes and stuff

    # stash a couple o' entries

    $store->new_model_object('Entry',
        uri => '/foo',
        tags => [qw/ perl moosex /],
    )->store;

    $store->new_model_object('Entry',
        uri => '/bar',
        tags => [qw/ perl dist::zilla /],
    )->store;

    # and later on...

    # retrieve from its key
    my $entry = $store->get( Entry => '/foo' );

    # get all entries tagged with Perl
    my @entries = map { $_->entry } 
                      $store->search( 'EntryTag' => { 
                        tag => 'perl' 
                      } )->all;

    # get all tags
    say join ' ', $store->all_tags;

Pretty sweet, isn't it?  Of course,  there is some arcane stuff going on
behind the scene. Maybe a tad more than I had hoped for, but definitively less
than you'd expect. 

## The apparatus behind the curtain

So, what did I have to do to make all of that work together? Let's go from top
to bottom. 

### Defining constraint types

First, I had to define my constraint types for my store:

    #syntax: perl
    use Galuga::Store::Types;

    use strict;
    use warnings;

    use MooseX::Storage::Engine;

    use MooseX::Types -declare => [qw/
        URIClass
        DateTimeClass
        SetClass;
    /];

    use Moose::Util::TypeConstraints;
    use URI;
    use Set::Object;
    use DateTime;
    use DateTime::Format::ISO8601;

    class_type 'SetClass' => { class => 'Set::Object' };

    coerce 'SetClass' 
        => from 'ArrayRef' 
        => via { Set::Object->new(@{shift @_}) };

    MooseX::Storage::Engine->add_custom_type_handler(
        'SetClass' => (
            expand   => sub { Set::Object->new(@{shift @_}) },
            collapse => sub { [ (shift)->elements ] },
        ),
    );

    class_type 'URIClass' =>  { class => 'URI' };

    coerce URIClass => from 'Str' => via { URI->new(shift) };

    MooseX::Storage::Engine->add_custom_type_handler(
        'URIClass' => (
            expand   => sub { URI->new(shift) },
            collapse => sub { (shift)->as_string },
        ),
    );

    class_type 'DateTimeClass' => { class => 'DateTime' };

    MooseX::Storage::Engine->add_custom_type_handler(
        'DateTimeClass' => (
            expand   => sub { 
                DateTime::Format::ISO8601->parse_datetime(shift) 
            },
            collapse => sub { (shift)->iso8601 },
        ),
    );

    1;

Mostly boilerplate [Moose::Util::TypeConstraints](cpan) stuff, with one
extra bit: the registration of handlers for those types for 
<cpan type="module">MooseX::Storage::Engine</cpan>.  

Funnily enough, that registration (which makes serialization of attributes
being non-MooseX::Storage-enabled objects a breeze, huzzah!) only came in the
last version of `MooseX::Storage`. Which I didn't have. So I began to [hack my
own](https://github.com/yanick/MooseX-Storage/tree/serialize-attribute) where
the serializer is passed as an argument to the attribute, and the
deserialization is dealt with by the already-defined coercion. With that way
of doing things, the code required to make a `DateTimeClass` attribute 
`MooseX::Storage`-friendly would have been:

    #syntax: perl
    has date_created => (
        traits => [ 'Serialize' ],
        is => 'rw',
        isa => 'DateTimeClass',
        coerce => 1,
        serializer => sub { (shift)->iso8601 },
    );

Now, I do see the wisdom in making the serialization and deserialization based
on the constraint type and not on the attribute (DRY, baby, DRY). At the same
time, I kinda wish that `MooseX::Storage` could take advantage of the coercion
functions, if they are already defined. At that point, I thought of writing a
patch that would allow to tell `MooseX::Storage` to do exactly that, via
passing the keyword `coerce` to `expand` instead of a coderef:


    #syntax: perl
    MooseX::Storage::Engine->add_custom_type_handler(
        'DateTimeClass' => (
            expand   => 'coerce',
            collapse => sub { (shift)->iso8601 },
        ),
    );

And then I began to dream that it would be even niftier if we brought the
solution one level lower in the food chain, and didn't only gave coercion
instructions to constraint types, but also serialization tips:

    #syntax: perl
    coerce 'SetClass' 
        => from 'ArrayRef' 
        => via { Set::Object->new(@{shift @_}) };

    serialize 'SetClass' => via { return [ (shift)->elements ] };

I actually began to look into `Moose::Meta::TypeConstraint` and squeeze some
attributes past the radar and into its inner hashref. And it wasn't going too
bad, but then I realized that I was beginning to shave the sherpa alongside
the herd, so I put that particular experiment on ice. I might come back to it
later.

### Hiring a store manager

Below that, I wrote to helper classes for `DBIx::NoSQL`. The first is a 
thin wrapper around <cpan type="module">DBIx::NoSQL::Store</cpan>, 
which mostly adds the capacity of finding all the model classes
of the store and set up their indexes and deserialization handlers (the
serialization will be handler by the models themselves, as we'll see next).

    #syntax: perl
    package DBIx::NoSQL::Store::Manager;

    use Moose;

    extends 'DBIx::NoSQL::Store';

    use DBIx::NoSQL::Store;
    use Method::Signatures;
    use Module::Pluggable require => 1;

    has models => (
        traits => [ 'Hash' ],
        is => 'ro',
        isa => 'HashRef',
        lazy => 1,
        default => method {
            my ( $class ) = $self->meta->class_precedence_list;

            search_path( $self, new => join '::', $class, 'Model' );

            return { 
                map { _model_name($_) => $_ } 
                    plugins( $self, plugins ) 
            };
        },
        handles => {
            all_models        => 'keys',
            all_model_classes => 'values',
            model_class       => 'get',
        },
    );

    sub _model_name {
        my $name = shift;
        $name =~ s/^.*::Model:://;
        return $name;
    }

    method register {
        for my $p ( $self->all_model_classes ) {
            my $model = $self->model( $p->store_model );
            
            $model->_wrap( sub {
                my $inflated = $p->unpack($_[0]);
                $inflated->store_db($self);
                return $inflated;
            });

            $model->index(@$_) for $p->indexes;
        }
    };

    method new_model_object ( $model, @args ) {
        $self->model_class($model)->new( store_db => $self, @args);   
    }

    1;

### Here comes a huge dollop of glue

Finally, the role that spreads the NoSQL goodness over the model classes.
It adds accessors to the NoSQL store manager object (natch), a way to
define the model name that is going to be used within the said store,
two ways to define the key to use in the store (either label an attribute
to be the store key or use a custom function to generate more complicated
keys), a trait to plaster on attributes we want to use as indexes, 
a little bit of wiring to make `DBIx::NoSQL` uses the serialization 
provided by `MooseX::Storage`, and a few extra goodies for the fun of it.


    #syntax: perl
    package DBIx::NoSQL::Store::Model::Role;

    use Moose::Role;

    use Method::Signatures;
    use MooseX::ClassAttribute;
    use MooseX::Storage 0.31;

    with Storage;
    with 'DBIx::NoSQL::Store::Model::Role::StoreKey',
        'DBIx::NoSQL::Store::Model::Role::StoreIndex';

    has store_db => (
        traits => [ 'DoNotSerialize' ],
        is       => 'rw',
    );

    class_has store_model => (
        isa => 'Str',
        is => 'rw',
        default => method {
            # TODO probably over-complicated
        my( $class ) = $self->class_precedence_list;

        $class =~ s/^.*?::Model:://;
        return $class;
        },
    );

    has store_key => (
        traits => [ 'DoNotSerialize' ],
        is => 'ro',
        lazy => 1,
        default => method {
        for my $attr ( grep {
                $_->does('DBIx::NoSQL::Store::Model::Role::StoreKey') 
        } $self->meta->get_all_attributes ) {
                my $reader = $attr->get_read_method;
                my $value = $self->$reader;

                die "attribute '", $attr->name, "' is empty" unless $value;

                return $value;
        }

        die "no store key set for $self";
        },
    );

    method store {
        $self->store_db->set( 
            $self->store_model =>
                $self->store_key => $self,
        );
    }

    method delete {
        $self->store_db->delete( $self->store_model => $self->store_key );
    }

    method _entity { $self->pack }

    method indexes {
      return map  { [ 
        $_->name, ( isa => $_->store_isa ) x $_->has_store_isa 
      ] }
             grep { 
       $_->does('DBIx::NoSQL::Store::Model::Role::StoreIndex') 
       }     $self->meta->get_all_attributes;
    }

    package DBIx::NoSQL::Store::Model::Role::StoreKey;

    use Moose::Role;
    Moose::Util::meta_attribute_alias('StoreKey');

    package DBIx::NoSQL::Store::Model::Role::StoreIndex;

    use Moose::Role;
    Moose::Util::meta_attribute_alias('StoreIndex');

    has store_isa => (
        is => 'rw',
        isa => 'Str',
        predicate => 'has_store_isa',
    );

    1;
    
## Tadah!

And that's it. For now, the itch is satisfied. I'll most probably release my
`DBIx::NoSQL::Store::Manager` and `DBIx::NoSQL::Store::Model::Role` on one
form or the other at some point, and I might still suffer from a bout of
dementia where I'll try to modify the behavior of
`Moose::Method::TypeConstraint`. But... not today. No hack today. Hack
tomorrow. 

There is always a hack tomorrow.
