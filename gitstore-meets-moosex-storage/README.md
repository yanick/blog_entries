---
created: 2013-05-16
tags:
    - Perl
    - MooseX::Storage
    - GitStore
---

# New And Improved: GitStore Meets MooseX::Storage

<div style="float: right">
<img src="__ENTRY_DIR__/val_approuve.png" alt="New and Improved!" width="300"/>
</div>

A new version of [GitStore](cpan) -- which uses Git repositories as a 
persistent bag o' stuff for your Perl code -- is now on its way to CPAN, with some
new small but (or so I think) nifty features.

<div style="clear: both">
</div>

## Autocommit

That one is a no-brainer. Up to now, to save the changes to the repo, one had
to explicitly commit them:

    #syntax: perl

    use GitStore;

    my $store = GitStore->new( './mystore' );

    $store->set( 'foo' => 'this' );
    $store->set( 'bar' => 'that' );

    $store->commit( 'a little bit of this and that');

which is fine and proper. But now, for the reckless at heart, we can also tell
the store to just commit'em as they come along:

    #syntax: perl

    use GitStore;

    my $store = GitStore->new( repo => './mystore', autocommit => 1 );

    $store->set( 'foo' => 'this' );
    $store->set( 'bar' => 'that' );

    # that's it

## Customizable serializer/deserializer

Up to now, if you were to shove a reference into the store, `GitStore`
would use [Storable](cpan) to serialize and deserialize the stuff.
Handy, but perhaps sometimes one want to save things in a readable format like
YAML? Well, now it's possible:

    #syntax: perl

    use GitStore;

    my $store = GitStore->new( 
        repo => './mystore', 
        serializer => sub {
            my( $store, $path, $value ) = @_;

            return $path =~ m#^json# 
                                ? encode_json($value)
                                : YAML::Dump($value)
                                ;
        },
        deserializer => sub {
            my( $store, $path, $value ) = @_;
            
            return $path =~ #^json#
                                ?decode_json($value)
                                : YAML::Load($value)
                                ;
        },
    );

    # will be saved as json
    $store->set( 'json/foo' => { a => 1 } ); 

    # and that one as yaml
    $store->set( 'yaml/bar' => [ 1..10 ] );

## Now Best Buddy With MooseX::Storage

And once we put together those two previous little bits of cleverness, and 
sprinkle a little bit of unicorn dust on top of it, we now have
`MooseX::Storage::IO::GitStore`, which acts as a [MooseX::Storage](cpan)
driver that serializes and stores your precious
Moose objects in the Git store.

    #syntax: perl
    package Point {  # the usual example
        use Moose;
        use MooseX::Storage;

        with Storage( format => 'YAML', io => 'GitStore');

        has 'x' => (is => 'rw', isa => 'Int');
        has 'y' => (is => 'rw', isa => 'Int');
    }

    my $p = Point->new(x => 10, y => 10);

    $p->store('my_point', git_repo => './store'); # hop! stashed away

    # ... and can easily be retrieved
    my $p2 = Point->load('my_point', git_repo => './store');


