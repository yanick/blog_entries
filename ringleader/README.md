---
title: A Ringleader Proxy for Sporadically-Used Web Applications
url: ringleader
format: markdown
created: 10 July 2014
tags:
    - Perl
    - HTTP::Proxy
---

As you might already know, I come up with my fair share of toy web applications. 

Once created, I typically throw them on my 
server for a few weeks but, as the resources of good ol' Gilgamesh are
limited, they eventually have to be turned off to make room
for the next wave of shiny new toys. Which is a darn shame, as some of them
can be useful from time to time. Sure, running all webapps all the time
would be murder for the machine, but there should be a way to only fire up the
application when it's needed.

Of course there's already a way of doing just that. You might have heard of
it: it's called CGI. And
while it's perfectly possible to run PSGI applications under CGI, it's also...
not quite perfect. The principal problem is that since there is no persistence
at all between requests (of course, with the help of mod_perl there *could* be
persistence, but that would defeat the purpose), so it's not exactly snappy.
Although, to be fair, it'd probably be still fast enough for most small
applications. But still, it feels clunky. Plus, I'm just plain afraid that if
I revert to using CGI, [Sawyer](http://www.youtube.com/watch?v=tu6_3fZbWYw)
will burst out of the wall like a vengeful Kool-Aid Man and throttle the life
out of me. He probably wouldn't, but I prefer not to take any chance.

So I don't want single executions and I don't want perpetual running. What I'd
really want is something in-between. I'd like the applications to be disabled 
by default, but if a request comes along, to be awaken and ran for as long as
there is traffic. And only once the traffic has abated for a reasonable amount
of time do I want the application to be turned off once more.

The good news is that it seems that Apache's
[mod_fastcgi](http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html#FastCgiConfig)
can fire dynamic
applications upon first request. If that's the case, then the waking-up part
of the job comes for free, and the shutting down is merely a question of
periodically monitoring the logs and killing processes when inactivity is
detected. 

The bad news is that I only heard that after I was already halfway done
shaving that yak my own way. So instead of cruelly dropping the poor
creature right there and then, abandoning it with a punk-like half-shave, I
decided to go all the way and see how a Perl alternative would look.

## It's all about the proxy

My first instinct was to go with [Dancer](cpan:release/Dancer) (natch). 
But a quick survey of the tools available revealed something even more finely
tuned to the task at hand: [HTTP::Proxy](cpan:release/HTTP-Proxy). That module
does exactly what it says on the tin: it proxies http requests, and allows you
to fiddle with the requests and responses as they fly back and forth. 

Since I own my domain, all my applications run on their own sub-domain name.
With that setting, it's quite easy to have all my sub-domains point to the port
running that proxy and have the waking-up-if-required and dispatch to the real
application done as the request comes in.

``` perl
use HTTP::Proxy;
use HTTP::Proxy::HeaderFilter::simple;

my $proxy = HTTP::Proxy->new( port => 3000 );

my $wait_time = 5;
my $shutdown_delay = 10;

my %services = (
    'foo.babyl.ca' => $foo_config,
    'bar.babyl.ca' => $bar_config,

);

$proxy->push_filter( request => 
    HTTP::Proxy::HeaderFilter::simple->new( sub {

            my( $self, $headers, $request ) = @_;

            my $uri = $request->uri;
            my $host = $uri->host;

            my $service = $services{ $host } or die;

            $uri->host( 'localhost' );
            $uri->port( $service->port );

            unless ( $service->is_running ) {
                $service->start;
                sleep 1;
            }

            # store the latest access time
            $service->store_access_time(time);
    }),
);

$proxy->start;
```

With this, we already have the core of our application, and only need a few more
pieces, and details to iron out.

## Enter Sandman

An important one is how to detect if an application is running, and when it
goes inactive. For that I went for a simple mechanism. Using
[CHI](cpan:release/CHI) to provides me with a persistent and central place to
keep information for my application.  As soon as an application comes up, I
store the time of the current request in its cache, and each time a new
request comes in, I update the cache with the new time. That way, the
existence of the cache tells me if the application is running, and knowing if
the application should go dormant is just a question of seeing if the last
access time is old enough.

``` perl
use CHI;

# not a good cache driver for the real system
# but for testing it'll do
my $chi = CHI->new(
    driver => 'File',
    root_dir => 'cache',
);

...;

# when checking if the host is running
unless ( $chi->get($host) ) {
    $service->start;
    sleep 1;
}

...;

# and storing the access time becomes
$chi->set( $host => time );

# to check periodically, we fork a sub-process 
# and we simply endlessly sleep, check, then sleep
# some more

sub start_sandman {
    return if fork;

    while( sleep $shutdown_delay ) {
        check_activity_for( $_ ) for keys %services;
    }
}

sub check_activity_for {
    my $s = shift;

    my $time = $chi->get($s);

    # no cache? assume not running
    return if !$time or time - $time <= $shutdown_delay;

    $services{$s}->stop;

    $chi->remove($s);
}

```

## Minding the applications

The final remaining big piece of the puzzle is how to manage the launching and shutting down
of the applications. We could do it in a variety of ways, beginning by
using plain `system` calls. Instead, I decided to leverage the 
service manager [Ubic](cpan:release/Ubic). With the help of
[Ubic::Service::Plack](cpan:release/Ubic-Service-Plack), setting a PSGI
application is as straightforward as one could wish for:

```perl
use Ubic::Service::Plack;

Ubic::Service::Plack->new({
    server => "FCGI",
    server_args => { listen => "/tmp/foo_app.sock",
                     nproc  => 5 },
    app      => "/home/web/apps/foo/bin/app.pl",
    port     => 4444,
});
```

Once the service is defined, it can be started/stopped from the CLI. And,
which is more interesting for us, straight from Perl-land:

``` perl
use Ubic;

my %services = (
    # sub-domain      # ubic service name
    'foo.babyl.ca' => 'webapp.foo',
    'bar.babyl.ca' => 'webapp.bar',
);

$_ = Ubic->service($_) for values %services;

# and then to start a service
$services{'foo.babyl.ca'}->start;

# or to stop it
$services{'foo.babyl.ca'}->stop;

# other goodies can be gleaned too, like the port...
$services{'foo.babyl.ca'}->port;

```

### Now all together

And that's all we need to get our ringleader going. Putting it all together,
and tidying it up a little bit, we get:

``` perl
use 5.20.0;

use experimental 'postderef';

use HTTP::Proxy;
use HTTP::Proxy::HeaderFilter::simple;

use Ubic;

use CHI;

my $proxy = HTTP::Proxy->new( port => 3000 );

my $wait_time      = 5;
my $shutdown_delay = 10;

my $ubic_directory = '/Users/champoux/ubic';

my %services = (
    'foo.babyl.ca' => 'webapp.foo',
);

$_ = Ubic->service($_) for values %services;

# not a good cache driver for the real system
# but for testing it'll do
my $chi = CHI->new(
    driver => 'File',
    root_dir => 'cache',
);


$proxy->push_filter( request => HTTP::Proxy::HeaderFilter::simple->new(sub{
            my( $self, $headers, $request ) = @_;
            my $uri = $request->uri;
            my $host = $uri->host;

            my $service = $services{ $host } or die;

            $uri->host( 'localhost' );
            $uri->port( $service->port );

            unless ( $chi->get($host) ) {
                $service->start;
                sleep 1;
            }

            # always store the latest access time
            $chi->set( $host => time );
    }),
);

start_sandman();

$proxy->start;

sub start_sandman {
    return if fork;

    while( sleep $shutdown_delay ) {
        check_activity_for( $_ ) for keys %services;
    }
}

sub check_activity_for {
    my $service = shift;

    my $time = $chi->get($service);

    # no cache? assume not running
    return if !$time or time - $time <= $shutdown_delay;

    $services{$service}->stop;

    $chi->remove($service);
}
```

It's not yet completed. The configuration should go in a YAML file, 
we should have some more safeguards in case the cache and the real state
of the application aren't in sync, and the script itself should be started by
Unic too to make everything Circle-of-Life-perfect. 
Buuuuut as it is, I'd say it's already a decent start. 

