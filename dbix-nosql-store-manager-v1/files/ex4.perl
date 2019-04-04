$store->create( 'Entry',
    url    => '/first',
    author => $author,
);

# prints 'necrohacker'
say $store->get( 'Entry', '/first' )->author->bio;
