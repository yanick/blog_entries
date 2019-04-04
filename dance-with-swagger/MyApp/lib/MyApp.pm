package Xmas;
# ABSTRACT: Do the Xmas things, web-style

use Dancer ':syntax';

use Dancer::Plugin::Swagger;

our $VERSION = '0.1';

get '/gift/:person_name' => sub { ... };

post '/gift/:from/:to' => sub { ... };

put '/wishes/:to' => sub { ... };

swagger_auto_discover;


true;
