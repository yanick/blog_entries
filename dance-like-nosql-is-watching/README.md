---
created: 2017-04-16
---

# Dance like NoSQL is watching

Here come a fast one that I have to get out of my head.

## First, there was DBIx::NoSQL

Lately I've returned to [DBIx::NoSQL](cpan:DBIx-NoSQL), 
which provides a simple, easy way to create key/value stores.
Simple? Yes, really dead simple. Like that kind of simple:

```perl
use DBIx::NoSQL;

my $store = DBIx::NoSQL->connect( 'store.sqlite' );

        #     model    id  
$store->set( Player => yenzie => {
    name => 'yenzie',
    alliance => 'Nefarious Coallition',
});

$store->set( Ship => enkidu => {
    name   => 'Enkidu',
    hull   => 10,
    coords => [ 10, 10 ],
});

```

In the background, `DBIx::NoSQL` creates a [DBIx::Class](cpan:DBIx-Class)
schema. All data structures are serialized and dumped in a big happy table,
while their ids are saved in per-model tables. Indexes can also be
added to models whenever we want

```perl
$store->model('Player')->index('alliance');
```

When new indexes are created, `DBIx::NoSQL` alters the schema dynamically in
consequence. And since the schema is `DBIx::Class`-based, its power is there
for searches when needed.

```perl
my @players = $store->search('Player')->where({ 
    # needs to be the id or an indexed field
    alliance => { like => qr/evil/ }
)->order_by( 'name DESC' )->all;
```

In a nutshell, it's a decent tool when setting up a MongoDB or CouchDB
instance -- let alone a full relational schema -- sounds like too much work.


## Then came along DBIx::NoSQL::Store::Manager

When I [originally played with it](http://techblog.babyl.ca/entry/shaving-the-white-whale)
I upped the antes and wrote
[DBIx::NoSQL::Store::Manager](cpan:DBIx-NoSQL-Store-Manager), which uses Moose
objects as models. Which let you create the class
`MyStore::Model::Player`, and the system will figure it out from there.

```perl
package MyStore::Model::Player;

use Moose;
use MooseX::MungeHas 'is_ro';

with 'DBIx::NoSQL::Store::Manager::Model';

has name     => ( traits  => [ 'StoreKey' ] );
has alliance => ( traits  => [ 'StoreIndex' ] );

1;
```

## And now... lights on the dancefloor...

And so last week I was musing on how easy this allows to 
set up a quick'n'dirty NoSQL backend. Then I thought... and what if
we push that DWIMery all the way to a REST interface?

So I fired up the ol' Dancer environment, hacked for an hour or two, and now I
have... no, let's show, not tell.

##hackthrough

### ./config.yaml

I'm skipping the non-important parts of the `config.yml`.
All that matter for us right now is that we serialize using `JSON`,
and set a database and store manager class for the store plugin.

### ./store.perl

As you can see, the main store class is straightforward. 

Mind you,
in a future iteration I might streamline things further and just build
the class automatically if no customization is required. But that's a yak for
a different day.

### ./player.perl

Model class. Still short and sweet.

### ./app.perl

The Dancer app. All of it.

No, really, that's all of it.

##/hackthrough

## And we DANCE!

##hackthrough

### ./post.bash

Player creation.

By the by, I'm using [HTTP Pie](https://httpie.org/)
as my REST tool. It's really nice.

### ./get.bash

Yup, it's there.

### ./put.bash

Updates work.

### ./put_bad.bash

... but not on ready-only values. 

Right now the exception value is an ugly trace. It'll eventually
get prettier.

### ./put_bad2.bash

... or unknown attributes.

### ./delete.bash

We can delete too, natch.

##/hackthrough

C'mon. You have to admit. It's all pretty sweet, isn't?

## Last notes

The code for the plugin can be found on
[GitHub](https://github.com/yanick/Dancer2-Plugin-StoreManager),
although it's still purely in its Proof-of-Concept stage. I'll try
to groom it for CPAN if there is a demand.

I'm also in the midst of updating `DBIx::NoSQL::Store::Manager` itself,
and I'm also making inquiries about `DBIx::NoSQL`, which would
need to have a few things updated (mostly, it's using `Any::Moose`,
which has been deprecated since). I would also love to see `DBIx::NoSQL`
adopting more backends. I heard smashing recommendations for Postgres and
its JSON support, so the mix of the two could be interesting (well, to me, at
least).



