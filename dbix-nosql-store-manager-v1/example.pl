use 5.20.0;

use lib '.';
use lib '../../lib';

use Blog;

my $store = Blog->connect( 'mystore.sqlite' );

my $auth = Blog::Model::Author->new(
    name => 'Bobby',
    bio  => 'Of Tablish fame',
);

$store->set( $auth );

my $author = $store->create( 'Author',
    name => 'Yanick',
    bio  => 'necrohacker',
);

my $entry = $store->create( 'Entry',
    url    => '/first',
    author => $author,
);

## later on

say $store->get( 'Entry', '/first' )->author->bio;

## you can pass the entry's id too

$entry = $store->create( 'Entry',
    url    => '/with_id',
    author => { name => 'Foo' },
);

$entry = $store->create( 'Entry',
    url    => '/with_id',
    author => 'Yanick',
);

say $entry->author->bio;

$store->create( 'Entry', 
    url => '/with_tags',
    author => 'Yanick',
    tags => [ 'perl', 'moose' ],
);

$store->create( 'Entry', 
    url => '/also_with_tags',
    author => 'Yanick',
    tags => [ 'perl' ],
);

# prints '/with_tags'
say $_->entry
    for $store->search(Tag => { tag => 'moose' } )->all;

