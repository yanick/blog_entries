---
package Blog::Model::Entry;

use strict;
use warnings;

use Moose;

with 'DBIx::NoSQL::Store::Manager::Model';

__PACKAGE__->meta->make_immutable;

1;
