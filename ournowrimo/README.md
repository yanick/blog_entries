---
title: NaNoWriMo Graph Web Application with Dancer
url: ournowrimo
format: markdown
created: 14 Nov 2010
tags:
    - Perl
    - Dancer
    - NaNoWriMo
    - AxKit
---

<div style="float: right; margin: 5px;">
<img src="__ENTRY_DIR__/so-you-think-you-can-dance-canada.jpg"
    alt="So You Think You Can Dance, Canada?" />
    <p>playing on the other channel: <i>Hellcatalyst</i></p>
</div>

My dragon has been a participant of [NaNoWriMo](http://www.nanowrimo.org/) --
the National Novel Writing Month -- for several years. 
A long, long time ago I wrote a small graphing web application for her and her
friends to keep track of their word count throughout the month.  It
was built using [AxKit](cpan) and to say that
this application was getting long in the tooth would be, *aah...*, kind to it. 
It was only a question of time before bit rot
would finally take its due, so it was not a huge surprise when it kinda went
belly-up this year.

I could probably have to resuscitate the old work-horse, but I decided instead
to take
this occasion to do something I wanted to do for a long time: 
give a whirl to [Dancer](cpan).

Dancer touts itself as a lightweight, yet-powerful web application framework. As 
we will see in a few lines, it sure seems to live up to both promises.
These days I'm mostly writing web applications using [Catalyst](cpan),
and if we compare both frameworks, Catalyst could be seen as a full-fledged Broadway
extravaganza, complete with girls clad in pheasant feathers, swimming 
pools, bears on unicycles and a philharmonic orchestra, Dancer has 
the simplicity and strength of a solo tap-dancing act. There's nothing wrong
with either, mind you, both
approaches are good and justified. Sometimes, you *do* need the unicycled
bears.  But other times, you want small and fast.

But enough about the hype. Let's see how hard it was to get my app up and
running, shall we?

## The Specs

At the core, the word count of all participant
is kept in a csv file looking like this:

<pre code="plain">
2010-11-01,Andy,0
2010-11-01,Bernadette,0
2010-11-01,Claude,0
2010-11-02,Bernadette,120
</pre>

The graph is only going to be used for one month, so there's no need to be any
fancier.  Not to mention that the csv format makes it very easy to edit badly entered counts when
someone will make a boo-boo.

The application we need around that is very simple. Basically, we need:

* A main page, showing a graph and a form to enter new results.
* An auxiliary page to process the input of a new word count.

Got it? Now, let's get crackin'.

## Creating the App

As with Catalyst, creating the skeleton of a new application in Dancer is incredibly
complicated. First, you have to do

<pre code="bash">
$ dancer -a ournowrimo
</pre>

and then, uh, you're done.  Okay, so maybe it's not that complicated after
all. :-)

My personal template system of choice these days is [Mason](cpan), so I
also edited the configuration file and changed the default templating system for the app to use
[Dancer::Template::Mason](cpan): 

<pre lang="plain">
logger: "file"
appname: "ournowrimo"
template: mason
</pre>

## Adding the Actions

By now, we have an application that is already in working order. It won't do
anything, but if we were to launch it by running

<pre code="bash">
$ ./ournowrimo.pl
</pre>

it would do it just fine.

### The Main Page

The routes (i.e., the urls that the app will recognize and act upon) are
defined in `lib/ournowrimo.pm`.  

For the main page, we don't do any heavy processing, we just want to invoke
a template:

<pre code="perl">
get '/graph' => sub {
    template 'index', { wrimoers => get_wrimoers() };
};
</pre>

That's it. For the url `/graph`, Dancer will 
render the template `views/index.mason`, passing
it the argument `wrimoers` (which is conveniently
populated by the function `get_wrimoers()`).

I'll not show the Mason template here, as it's
a fairly mundane HTML affair, but you can peek
at it at the application's Github repo (link below).  

The only interesting bit to it is that I'm 
using the [Flot](http://code.google.com/p/flot/)
jQuery plotting library to generate the graph,
and am using an AJAX call to get its data. Which
means that we need a new AJAX route for our application.

### Feeding graph data via AJAX

For the graph, we need the url `/data` to return 
a JSON representation of the wordcount data. Nicely enough,
Dancer has a `to_json()` function that takes care of the 
JSON encapsulation. All that is left for us to do, really, is 
to do the real data munging:

<pre code="Perl">
get '/data' => sub {
    open my $fh, '&lt;', $count_file;

    my %contestant;
    while (&lt;$fh>) {
        chomp;
        my ( $date, $who, $count ) = split '\s*,\s*';

        $contestant{$who}{ 1000 * DateTime::Format::Flexible->parse_datetime($date)->epoch } = $count;
    }

    my @json;  # data structure that is going to be JSONified

    while ( my ( $peep, $data ) = each %contestant ) {
        push @json, { 
            label     => $peep,
            hoverable => \1,    # so that it becomes JavaScript's 'true'
            data => [ map  { [ $_, $data->{$_} ] } 
                      sort { $a &lt;=> $b } 
                      keys %$data ],
          };
    }

    my $beginning = DateTime::Format::Flexible->parse_datetime( "2010-11-01")->epoch;
    my $end       = DateTime::Format::Flexible->parse_datetime( "2010-12-01")->epoch;

    push @json, {
        label => 'de par',
        data => [
            [ $beginning * 1000, 0],
            [ DateTime->now->epoch * 1_000, 50_000 * ( DateTime->now->epoch - $beginning ) / ( $end - $beginning ) ]
        ],

    };

    to_json( \@json );
};
</pre>

For more serious AJAX interaction, there's also the
[Dancer::Plugin::Ajax](cpan) module that adds
the `ajax` route handler, but in our case a simple `get` 
is just fine.

### Processing New Entries

For the entry of a new word count, we are taking in a form request with two
parameters, *who* and *count*:

<pre code="Perl">
get '/add' => sub {
    open my $fh, '>>', $count_file;
    say $fh join ',', DateTime->now, params->{who}, params->{count};
    close $fh;

    redirect '/';
};
</pre>

Seriously, could things get any easier?

### Bonus Feature: Throwing in an Atom Feed

Since everything else resulted in a ridiculously small amount of code, 
I decided to add a feed to the application to let everybody know of 
wordcount updates.  Surely that will require a lot more coding?

<pre code="Perl">
get '/feed' => sub {
    content_type 'application/atom+xml';

    # $feed is a XML::Atom::SimpleFeed object
    my $feed = generate_feed();

    return $feed->as_string;
};
</pre>

... Seemingly not, it won't.

## Deployment

Dancer, just like Catalyst, can be deployed a gazillion different ways. 
As a standalone server (development heaven), as CGI (likely to be *sloooow*,
but nice to it's there if everything else fail), as FastCGI, and as a
[Plack](cpan) application.  My web server is still using Apache 1 and
has the cruft of a decade in its configuration files,  so to find the right way
to deploy for me was trickier than it should be.  But eventually I found
something that worked for me.  I launched the app as a plack-backed fastcgi 

<pre code="bash">
plackup -s FCGI --listen /tmp/ournowrimo.socket ournowrimo.pl
</pre>

and configured Apache to treat it as an external fastcgi server

<pre code="plain">
Alias /wrimo/ /tmp/ournowrimo.fcgi/
FastCgiExternalServer /tmp/ournowrimo.fcgi -socket /tmp/ournowrimo.socket
</pre>

## The Result

<div align="center">
<img src="__ENTRY_DIR__/ournowrimo.png" alt="screenshot" />
</div>

## Peek at the Code on Github

As usual, the full application  is available on [GitHub](http://github.com/yanick/ournowrimo).




