package DancerTest;

use strict;
use warnings;

use Moose;
 
extends 'DBIx::NoSQL::Store::Manager';
 
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
