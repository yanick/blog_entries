$entry = $store->create( 'Entry',
    url    => '/with_id',
    author => { name => 'Yenzie', bio => 'twitterer' },
);

# prints 'twitterer'
$store->get( 'Author', 'Yenzie' )->bio;

