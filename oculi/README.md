---
title: The Hills Have Multi-Faceted Eyes
url: oculi
format: markdown
created: 2015-01-07
tags:
    - Perl
---

As your typical, slightly OCD computer geek, there is
only one thing more engrossing to me than statistics.
Namely: statistics presented as pretty graphs.

For a little while now I had two specific pieces
of technology I wanted to play with: [InfluxDB](http://influxdb.com),
a database for time series, and [Grafana](http://grafana.org), a JavaScript-based
graph dashboard for [Graphite](http://graphite.wikidot.com) and InfluxDB.
So, having a little bit of time over the Holidays, I thought it was a good
time
to revisit my [past metric-collecting
ideas](http://techblog.babyl.ca/entry/varys), and see how I could reinterpret 
them using InfluxDB as the core database and Grafana as its visualization.

## It's all about ease of writing metric gathering modules

For the initial prototype, I decided to implement two simple metrics. One
that grabs the ink levels of a Brother printer (fairly easy task, as the
printer has a web interface providing that information), and a second that
records the current backlog of email folders.  

### Ink-ant believe how easy this is

The main goal was to make
writing those metric gathering modules as simple and free of overhead as
possible. So for the printer check I ended up with

```perl
package App::Oculi::Metric::Printer::Ink;

use Web::Query;

use Moose;

with 'App::Oculi::Metric';

has printer => (
    traits => [ 'App::Oculi::SeriesIdentifier' ],
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has host => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->get_service( host => { resource => $self->printer } );
    },
);

sub gather_stats {
    my $self = shift;

    my $url = sprintf "http://%s/general/status.html", $self->host;

    my %stats;
    wq($url)->find( 'img.tonerremain' )->each(sub{
        no warnings;  # height = 88px so complains because not numerical
        $stats{  $_->attr('alt') } =  $_->attr('height') / 50;
    });

    return \%stats;
}

1;
```

Not terribly complex isn't? Basically, the metric module needs to specify
the different attributes it really needs to know (here the printer name and
its host address), and the `gather_stats` function which does the real work of 
getting the stats. 

Two magic things to note. First, the name of the series that will hold
the data in InfluxDB is automatically generated from the module's name as well 
as the attributes having the `SeriesIdentifier` trait (so here the label would
be `printer.ink./printer_name/`). Second, the `host` attribute is related to
the printer name and, in theory, if you have the latter the former should
always be the same. That linking is exactly what the `default` there is for. How does it do
its magic? That we'll see in the next sections.

### Email be unto something here...

The email backlog metric module is barely more complex:


```perl
package App::Oculi::Metric::Email::Backlog;

use Moose;

with 'App::Oculi::Metric';

my $i = 0;
has $_ => (
    traits => [ qw/ App::Oculi::SeriesIdentifier / ],
    isa => 'Str',
    is => 'ro',
    required => 1,
    series_index => $i++,
) for qw/ server user mailbox /;

has imap => (
    isa => 'Net::IMAP::Client',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->get_service( imap => {
                server => $self->server,
                user => $self->user,
        });
    },
);

sub gather_stats {
    my $self = shift;

    return {
        emails => $self->imap->status( $self->mailbox )->{MESSAGES}
    };
}

1;
```

The main difference is that now the series label has three components (the
server name, the user and the mailbox), so we need to tell the
`SeriesIdentifier` trait in which order to glue them together. We also need
a [Net::IMAP::Client](cpan:release/Net-IMAP-Client)  object to fetch our data,
but like in the previous example, we let the mysterious `get_service` method
create it for us.

### An `App::Oculi::Metric` ton of magic

That section title is a lie, really. For the role making the
foundation of the metric modules is relatively benign.

```perl
package App::Oculi::Metric;

use Moose::Role;

has oculi => (
    isa => 'App::Oculi',
    is => 'ro',
    required => 1,
    handles => [ 'get_service' ],
);

has metric_name => (
    isa => 'Str',
    is => 'ro',
    default => sub {
        my $self = shift;

        my ( $class ) = $self->meta->class_precedence_list;

        $class =~ s/^App::Oculi::Metric:://;
        $class =~ s/::/./g;

        return $class;
    },
);

sub series_label {
    my $self = shift;

    my %attrs = map { 
        my $att = $self->meta->get_attribute($_);
        $att->does('App::Oculi::SeriesIdentifier') ? ( $_ => $att->series_index ) : () 
    } $self->meta->get_attribute_list;

    my @attrs = sort { $attrs{$a} <=> $attrs{$b} } keys %attrs;

    return join '.', map { lc } $self->metric_name, map { $self->$_ } @attrs;
}

1;
```

There's a little meta introspection to figure out the series name, 
we add access to a main `oculi` object, and that's it.

## It's all about the ease of adding new metrics

So writing metric gathering modules is fairly painless. But for the end-user,
the main thing is how easy it is to define and collect instances of those metrics.

Taking a page off Ansible's book, I decided to use YAML to define the stats we
wish to have gathered.

```yaml
# checks.yml
---
- metric: Printer::Ink
  printer: nidaba
- metric: Email::Backlog
  server: gilgamesh
  user: yanick
  mailbox: inbox
```

Short, sweet, and straight to the point. But where the system get the rest of
the information -- the ip addresses, the credentials, etc -- for those checks?
From a `resources` section of a main configuration file:

```yaml
# oculi.yml
---
influx:
    server: enkidu
    database: oculi
    user: root
resources:
    enkidu:
        host: 192.168.0.103
        influxdb:
            users:
                root:
                    password: root
    gilgamesh:
        host: 192.168.0.100
        imap:
            users:
                yanick:
                    password: hush
    nidaba:
        host: 192.168.0.120

```

The logic being that many checks will need parts and pieces of that
information, so we'll keep it in a centralized location. But we don't want
every check that need an IMAP server to independently go spelunking in it, as
this will mean duplicating almost-identical code all over the place. Rather,
we want a main service broker that takes in the minimal set of arguments ("I
want an imap connection to yanick's folders on Gilgamesh"), and give you the 
right object.

And that's what the main `App::Oculi` object is for.

## It's all about the ease of--just kidding. Prepare to shriek.

The secret sauce of `App::Oculi` to put all the pieces together is nothing
else than [Bread::Board](cpan:release/Bread-Board). But it's nowhere as scary
as you would think. If you look at the code below, for each service I want
to be able to provide -- like, say, the imap object -- a function `imap_container`
creates a Bread::Board container that takes the set of arguments passed by the 
metric instance, the resource configuration tree, and figures out how 
generates the desired object out of them.

```perl
package App::Oculi;

use Moose;

use Bread::Board;
use Class::Load qw/ load_class /;

has [ qw/ influx resources / ] => (
    isa => 'HashRef',
    is => 'ro',
    required => 1,
);

has influxdb => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        $self->get_service( influxdb => $self->influx );
    }
);

has board => (
    is => 'ro',
    lazy => 1,
    builder => '_build_board',
);

sub _build_board {
    my $self = shift;
    
    my $c = container 'resources' => as {
        service config => block => sub { $self->{resources} };
    };

    my $services = container 'services' => as { };

    $services->add_sub_container( $self->$_ ) for qw/
        imap_container
        host_container
        influxdb_container
    /;

    $c->add_sub_container($services);

    return $c;
}

sub host_container {
    container host => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                resource => depends_on('Args/resource'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;
                $s->param('config')->{$s->param('resource')}{host};
            }
        )
    };
}

sub influxdb_container {
    container influxdb => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                server => depends_on('Args/server'),
                database => depends_on('Args/database'),
                user   => depends_on('Args/user'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;

                my( $server, $user, $database, $config ) = map { $s->param($_) } qw/
                    server user database config
                /;

                $config = $config->{$server};

                load_class( 'InfluxDB' );

                return InfluxDB->new(
                    host => $config->{host},
                    username => $user,
                    password => $config->{influxdb}{users}{$user}{password},
                    database => $database,
                );
            }
        )
    };
};

sub imap_container {
    container imap => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                server => depends_on('Args/server'),
                user   => depends_on('Args/user'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;

                my( $server, $user, $config ) = map { $s->param($_) } qw/
                    server user config
                /;

                $config = $config->{$server};

                load_class( 'Net::IMAP::Client' );

                my $client = Net::IMAP::Client->new(
                    server => $config->{host},
                    user => $user,
                    pass => $config->{imap}{users}{$user}{password},
                    ssl => 1,
                    ssl_verify_peer => 0,
                );

                $client->login;

                return $client;
            }
        )
    };
}

sub get_service {
    my( $self, $service, $args ) = @_;

    my $c = Bread::Board::Container->new(name => 'Args' );

    while( my($k,$v)  = each %$args ) {
        $c->add_service( Bread::Board::Literal->new( name => $k, value => $v));
    }

    return $self->board->fetch( "/services/$service" )->create( Args => $c )->resolve(
        service => 'object'
    );

}

sub write_points{
    my( $self, @args ) = @_;
    $self->influxdb->write_points(@args) or die $self->influxdb->errstr;
}

1;
```

## It's all about the ease of running the darn thing

We have metrics, we have a way to define their instances, and we have a scary
core monster that provides magic glue that bind it all together. 
All that remains is a way to run the thing. 

```perl
package App::Oculi::Command::Gather;

use MooseX::App::Command;

use YAML;
use Data::Printer;
use Class::Load qw/ try_load_class /;
use App::Oculi;

use 5.20.0;

option config => (
    is => 'ro',
    default => 'oculi.yml'
);

option verbose => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
);

option dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    trigger => sub { $_[0]->verbose(1) if $_[1] }
);

parameter checks => (
    is => 'ro',
    isa => 'ArrayRef',
);

has "oculi" => (
    isa => 'App::Oculi',
    is => 'ro',
    lazy => 1,
    default => sub { 
        App::Oculi->new( YAML::LoadFile( $_[0]->config ) ); 
    },
);

sub run {
    my $self = shift;

    for my $file ( @{ $self->checks } ) {
        say "loading '$file'..." if $self->verbose;

        my $content = YAML::LoadFile($file);
        my @checks = ref $content eq 'ARRAY' ? @$content : ( $content );

        for my $c ( @checks ) {
            $self->run_check($c);
        }
    }

}

sub run_check {
    my( $self, $config ) = @_;

    my $metric = delete $config->{metric};

    say "metric: $metric" if $self->verbose;

    my $module = "App::Oculi::Metric::$metric";
    try_load_class( $module ) or die "couldn't load $module";

    my $check = $module->new( oculi => $self->oculi, %$config );

    my $series = $check->series_label;

    say "series: $series" if $self->verbose;

    my $stats = $check->gather_stats;

    say p($stats) if $self->verbose;

    $self->record( $series => $stats ) unless $self->dry_run;
}

sub record {
    my( $self, $series, $stats ) = @_;

    # TODO right now we only accept a single point. Boring
    $self->oculi->write_points(
        data => {
            name => $series, 
            columns => [ keys %$stats ],
            points => [ [ values %$stats ] ]
        },
    );

}

1;
```

And with that, lo and behold:

```bash
$ perl -Ilib bin/oculi gather --verbose checks.yml
loading 'checks.yml'...
metric: Printer::Ink
series: printer.ink.nidaba
\ {
    Black     0.58,
    Cyan      0.24,
    Magenta   0.24,
    Yellow    0.16
}
metric: Email::Backlog
series: email.backlog.gilgamesh.yanick.inbox
\ {
    emails   3563
}
```

## It's all about the ease of-- they, wait, we're done?

Yep, we're pretty much done. The data is pushed to InfluxDB,
and we can now do whatever we want with it in Grafana 
(using [http_this](cpan:release/App-HTTPThis) if you don't even want to bother
with Apache or Nginx).

![screenshot](__ENTRY_DIR__/oculi.png)

The prototype, as it stands at the moment, is available
[on GitHub](gh:yanick/oculi). Enjoy!

