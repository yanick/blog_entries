$entry = $store->create( 'Entry',
    url    => '/with_id',
    author => 'Yanick',
);

# still prints 'necrohacker'
say $entry->author->bio;
