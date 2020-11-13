package Proto::Store::Model::Player;

use 5.20.0;

use Moose;
use MooseX::MungeHas { 
    has_ro => [ 'is_ro' ], 
    has_rw => [ 'is_rw' ] 
};

with 'DBIx::NoSQL::Store::Manager::Model';

has_ro name => (
    traits   => [ 'StoreKey' ],
    required => 1,
);

has_rw alliance => (
    traits   => [ 'StoreIndex' ],
);

1;
