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
