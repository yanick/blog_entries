use 5.20.0;

use lib 'lib';

use Example::Main;

say Example::Main->new( 
    title => 'Hello world!',
    items => [ 'this', 'skip_me', 'me_too', 'that' ] 
)->render;
