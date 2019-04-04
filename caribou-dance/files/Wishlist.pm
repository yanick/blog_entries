package Wishlist;

use strict;
use warnings;

use Moose;

use Template::Caribou;
use Template::Caribou::Tags::HTML qw/ :all /;

with 'Template::Caribou', 
     'Template::Caribou::Files',
     'Template::Caribou::DevServer';

has '+template_dirs' => (
    default => sub { [ 'templates' ] },
);

has wishlist => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

1;
