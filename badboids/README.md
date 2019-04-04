---
title: BadBoids, BadBoids, Watcha Gonna Do...
url: badboids
created: 2013-06-27
tags:
    - Perl
    - Twitter
    - Dancer
---

As is was [foretold](blog:atwitterpocalypse), the Atwitterpocalypse came and
went. And, as expected, the world didn't stop turning. Although a few
applications did. Amongst the victims, [Choqok][choqok], which was the client
of choice at the Chaos Cottage (aka Chez Yanick). 

So, forced by necessity, we began to shop for a new client. The official
Twitter webpage is... okay. [Tweetdeck][tweetdeck] has features, but its
interface is busy as heck. And... yeah, basically, all clients are almost, but
not quite, what we need.

... You know where this is going, right? 

Enter [BadBoids](gh:yanick/BadBoids), named in honor of the Chaos Cottage's
resident terrible three budgerigars. The goal: make a usable Twitter client
that does stuff our way.
Because I have a few good aces up my sleeve, I decided to go with a
Dancer-based web application. What I'm going to discuss in the next few
paragraphs are the great lines of the state of the app after a week-end of
hacking -- for the details, you can always go and check the GitHub repo. 
At this time, it's not yet
ready for prime-time, but as you'll see, it's already shaping up toward
something...

## Basic Stuff: Shake Hands With the Bird

Authentication and Twitter authorization are, pretty obviously, core to this app. Happily,
[Dancer](cpan:release/Dancer)'s plugins make it real easy. For the Twitter 
authorization stuff, we use
[Dancer::Plugin::Auth::Twitter](cpan:release/Dancer-Plugin-Auth-Twitter), and
for the application itself,
[Dancer::Plugin::Auth::Extensible](cpan:release/Dancer-Plugin-Auth-Extensible),
both straight up and without anything fancy. And when I say "without anything
fancy", I mean it. This is almost verbatim all that is needed in the code
itself to make both the local authentication and the twitter authorization
work:


``` perl
use Dancer::Plugin::Auth::Twitter;
use Dancer::Plugin::Auth::Extensible;

auth_twitter_init();

# everything on the site should be accessed only
# if logged in
hook before => sub {
    redirect '/login' unless logged_in_user() 
        or request->path eq '/login';
};

get '/' => sub {
    return template 'profiles' => {
        auth_url => auth_twitter_authenticate_url,
        user => logged_in_user(),
        profiles => [
            $store->search( Profile => {
                budgie_user => logged_in_user()->{user}
            })->all
        ],
    };
};

get '/authorized' => sub {
    # Ah! new twitter profile has been approved,
    # let's store it locally

    my $profile = session('twitter_user');

    $profile->{budgie_user} = logged_in_user()->{user};

    $store->set( Profile => $profile->{screen_name} => $profile );

    redirect "/profile/" . $profile->{screen_name};
};

```

For the moment, the local users are defined directly within the config file
via
[Dancer::Plugin::Auth::Extensible::Provider::Config](cpan:Dancer::Plugin::Auth::Extensible::Provider::Config),
and as you can surmise from the code above, one local user can have many
Twitter profiles (which is feature #1 we wanted).

## Building a Chicken Coop: Local Archive

Another feature I really wanted was to have a local archive of tweets, both
because it makes the application easier to manage and, well, because I like to
keep my friends close, and my backup closer.  

I didn't want to go through the
trouble of creating a full-fledged database schema to mirror the information
provided by the Twitter API, but I knew I'd want some searching capabilities.
So a NoSQL approach seemed to be the best approach. Eventually, I'll probably
try to use one of the big guys, but as a first brush, I just wanted to have
something to get me going, and for that [DBIx::NoSQL](cpan:release/DBIx-NoSQL) 
is exactly what I wanted. Again, this is pretty much all that is actually in
the app right now to retrieve and store (with indexes, thank-you-very-much)
tweets in a neat little SQLite database:

``` perl
use DBIx::NoSQL;

my $db = config->{database};
my $store = DBIx::NoSQL->connect([
    "dbi:SQLite:$db", undef, undef, { sqlite_unicode => 1 } 
]);

$store->model('Status')->index('budgie_profile');
$store->model('Status')->index('budgie_timeline');
$store->model('Status')->index('created_at', isa => 'DateTime');

$store->model('Profile')->index('budgie_user');

get '/profile/:profile/update' => sub {
    my( $profile, $twitter ) = get_profile(); 
    my $profile_name = $profile->{screen_name};

    my %updates;

    # fetch updates on mentions and home timelines
    $updates{timeline}{home}     = fetch_updates( $profile, $twitter, 'home' );
    $updates{timeline}{mentions} = fetch_updates( $profile, $twitter, 'mentions' );

    my @user_ids = uniq map { $_->{user}{id_str} } 
                        map { @$_ } map { $_->{status}  } 
                        values %{ $updates{timeline} };

    # also save the twitter users information locally
    for my $u ( @user_ids ) {
        next if $store->exists( 'Twitter_User' => $u );
        my $user = $twitter->show_user({ user_id => $u }) or next;
        $store->set( 'Twitter_User' => $u => $user );
        push @{ $updates{twitter_users} }, $user;
    }

    return \%updates;
};

sub fetch_updates {
    my ( $profile, $twitter, $timeline ) = @_;

    my $last = $store->search( 'Status' => {
        budgie_profile => $profile->{screen_name},
        budgie_timeline => $timeline,
    } )->order_by( 'created_at DESC' )->next;

    my $last_status_id = undef;

    my $max_count = 20;

    debug "Last $timeline status id: " . $last_status_id;

    my $method = $timeline . '_timeline';

    my @status = @{
        $twitter->$method({
            ( since_id => $last_status_id ) x !! $last_status_id,    
            count    => $max_count,
            trim_user => 1,
        })
    };

    for my $s ( @status ) {
        next if $store->exists( 'Status' => $s->{id_str} );
        $s->{budgie_profile}  = $profile->{screen_name},
        $s->{budgie_timeline} = $timeline,
        $s->{created_at} = DateTime::Format::Flexible->parse_datetime($s->{created_at});
        $store->set( 'Status' => $s->{id_str} => $s );
    }

    return {
        status => \@status,
        maybe_more => @status == $max_count,
    }
}

```

And with this we have the beating heart of the application. By accessing 
`/profile/$username/update` regularly (or having it ran via a cronjob'ed
script), we pump new tweets into the database, which can then be displayed any
way we want to the user.

## The Remaining Trivialities...

At this point, it's only a question to create a pretty interface. Not hard,
but, y'know, time consuming. For the moment the code on GitHub only shows a
single timeline (a 'firehose' holding both mentions and the home timeline),
but multiple timelines will be soon added via [jQuery UI's
tabs](http://jqueryui.com/tabs/). In the same vein, the display is still
crude: 

<div align="center">
<img alt="screenshot" src="__ENTRY_DIR__/badboids.png" />
</div>


but already we have the possibility to click-and-hide tweets, and
periodic updates already happen (with pending bugs, mind you, but it's there).
More will come soon.  And even sooner if anybody decide to join the fun and
fork the project (\**hint*\*, \**hint*\*). 






[choqok]: http://choqok.gnufolks.org/
[tweetdeck]: http://tweetdeck.com/


