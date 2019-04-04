package Xmas;
# ABSTRACT: Do the Xmas things, web-style

use Dancer ':syntax';

use Dancer::Plugin::Swagger;

our $VERSION = '0.1';

get '/gift/:person_name' => sub { ... };

swagger_definition gift_response => {
    type => 'object', required => [qw/ from to /] 
};

swagger_path {
    description => 'create a gift exchange',
    parameters => [
        { name => 'fragile',       in => 'body', type => 'boolean' },
        { name => 'ascii_picture', in => 'body', type => 'string' },
    ],
    responses => {
        default => { 
            description => "gift has been recorded",
            example => { from => 'Me', to => 'You', box => 'puppy-shaped' },
            schema => { '$id' => '#/definitions/gift_response' },
        },
        404 => { template => sub {
            +{ error => "giftee or gifter '$_[0]' not found" } } 
        },
    },
},
post '/gift/:from/:to' => sub { return {
        from => param('from'),
        to   => param('to'),
        box  => 'weird',
}};

put '/wishes/:to' => sub { ... };

swagger_auto_discover;

true;
