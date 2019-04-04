use Net::OAuth::Client;
use Net::OAuth::AccessToken;

get '/auth' => sub {
    # that one is simple...
    redirect auth_client->authorize_url;
};

get '/auth/callback' => sub {

    # get the access token from the web service...
    my $access = auth_client->get_access_token(
        param( 'oauth_token' ),
        param( 'oauth_verifier' ),
    );

    # ... and keep the information you need to rebuild it
    session rav_token        => $access->token;
    session rav_token_secret => $access->token_secret;
    session username         => param 'username';

    forward '/';
};

get '/timeline/:raveler' => sub {

    # access_token() is the good part there
    my $projects = from_json(
        access_token->get(
            join '/', '/projects', $raveler, 'list.json'
        )->content
    );

    # and do something with $projects...
};

# and yes, those two functions just scream to
# be Dancer::Pluginified

sub auth_client() {
    my $rav = config->{ravelry};

    return Net::OAuth::Client->new(
        $rav->{tokens}{consumer_key},
        $rav->{tokens}{consumer_secret},
        site                => 'https://api.ravelry.com',
        request_token_path  => '/oauth/request_token',
        authorize_path      => '/oauth/authorize',
        access_token_path   => '/oauth/access_token',
        callback            => uri_for( $rav->{callback} ),
        session             => \&session,
    );
}

sub access_token {
    return Net::OAuth::AccessToken->new(
        client       => auth_client(),
        token        => session( 'rav_token' ),
        token_secret => session( 'rav_token_secret' ),
    );
}
