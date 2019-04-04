package instatweets;

use Dancer ':syntax';

use Dancer::Plugin::Auth::Twitter;
use Dancer::Session;
use Dancer::Session::YAML;

auth_twitter_init();

# request of authentication,
# keep track of where we come from and pass it to Twitter
get '/authenticate' => sub {
    session( 'origin', params->{origin} );
    redirect auth_twitter_authenticate_url;
};

# authentication with Twitter succeeded, yay!
# stashing of tokens is done by D::P::A::T
# simply redirect whence we came from
get '/' => sub {
    my $url = session( 'origin' );
    redirect $url;
};

# returns a status of 200 if we are authenticated,
# 500 if not
get '/authenticated' => sub {
    Dancer::SharedData->response->status( 500 ) unless session 'access_token';
    'answer: success';
};

post '/tweet' => sub {
    twitter->access_token( session( 'access_token' ) );
    twitter->access_token_secret( session( 'access_token_secret' ) );
    twitter->update( params->{update} );
};

get '/fail' => sub {
    Dancer::SharedData->response->status( 500 );
    'FAIL';
};

true;

