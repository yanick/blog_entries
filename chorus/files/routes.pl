use AnyMQ;

my $bus = AnyMQ->new;
my $topic = $bus->topic('slides');

    # not the safest password ever,
    # but it's not like we need anything stronger either
my $token = join '', shuffle 'a'..'z';

$chorus::first_connect = 1;

# Web::Hippie routes
get '/new_listener' => sub {
    request->env->{'hippie.listener'}->subscribe($topic);
};
get '/message' => sub {
    my $msg = request->env->{'hippie.message'};

    if ( $chorus::first_connect ) {
        $chorus::first_connect = 0;
        $topic->publish( { master => $token } );
        return;
    }

    # only the leader send stuff
    return unless $msg->{master} eq $token;

    delete $msg->{master};

    $topic->publish( $msg );
};
