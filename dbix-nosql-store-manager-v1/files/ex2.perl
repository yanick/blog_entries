my $auth = Blog::Model::Author->new(
    name => 'Bobby',
    bio  => 'Of Tablish fame',
);

$store->set( $auth );
