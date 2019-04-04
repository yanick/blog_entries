---
title: A contact sheet for your website
url: contact-sheet
format: markdown
created: 2012-03-03
tags:
    - Perl
    - Dancer
---
I'm in the throes of a major redesign of the site of my comic book, 
[Académie des Chasseurs de Primes](http://academiedeschasseursdeprimes.ca).
Like any of those redesign, it involves a lot of CSS whack-a-mole. Fine-tuning
one page throws a second one slightly off another, and fixing that second one
causes unforseen effects on a third one. And so on, and so bloody forth.

Generally, to discover those oopsies, I have to navigate the whole site.
Bah, humbug. Wouldn't it be much efficient to have a single document showing all
of the site's page? Something like a contact sheet for the website, if you
will.  Well, let's see how hard that would be.

## Step 1. Generate a sitemap

If we want to look at all our pages, we must have a listing of them.
One of the sane ways of doing that is to have a sitemap for the website.
Fortunately, as the ACP website uses [Dancer](cpan), all I have to do is
to add [Dancer::Plugin::SiteMap](cpan) to the application and, hop, 
self-generated sitemap.  As a pleasant side-effect, I also have a sitemap to
feed Google.  Sweet.

## Step 2. Read the links of the sitemap

Using [WWW::Mechanize](cpan), it's a breeze. 

    #syntax: perl
    my $mech = Test::WWW::Mechanize->new;

    $mech->get_ok( "$root_url/sitemap" );

    my @links = $mech->links;


In the code snippet, I actually went a step further 
and used [Test::WWW::Mechanize](cpan). As I'm going to crawl
the site, why not formulate the script as a test suite to that we can 
get our contact sheet and a health report on the whole thing?  There's no
point in simply being awesome if we can be mega-awesome, right?

## Step 3. Grab the screenshots

For this part, we'll use [Selenium](http://seleniumhq.org/) via
[WWW::Selenium](cpan).

    #syntax: perl
    my $sel = Test::WWW::Selenium->new( 
        host => "localhost",
        port => 4444,
        browser => "*firefox",
        browser_url => $root_url,
    );

    $sel->start;

    for my $url ( map { $_->url } @links ) {
        $sel->open_ok( $url ) or next;

        ( my $screenshot_file = $url . ".png" ) =~ s#/#_#g;

        # Selenium wants an absolute path
        $sel->capture_entire_page_screenshot( file( $screenshot_file )->absolute );
    }

    $sel->stop;

Yes, in those few lines, we visited all of our website's pages and generated a
screenshot of every single one of them. Automation. I love it.

## Step 4. Generate the thumbnails

For this I went with the good old [GD](cpan) module. We take the pictures,
scale them down to a width of 300 pixels and save the result in a second file.

    #syntax: perl
    my $screenshot = GD::Image->newFromPng( $screenshot_file );
    my ( $width, $height ) = $screenshot->getBounds;
    my $scale = 300 / $width;

    my $thumbnail = GD::Image->new( 300, $scale * $height );
    $thumbnail->copyResampled($screenshot, ( 0 ) x 4, 
        300, $scale * $height,
        $width, $height, 
    );

    ( my $thumbfile  = $screenshot_file ) =~ s/(?=\.png)/_thumbnail/;
    print { file( $thumbfile )->openw } $thumbnail->png;

## Step 5. Put the contact sheet together

Since I'm working on my [Template::Caribou](cpan), I'm using it to
generate the contact sheet. As *Caribou* is a work in progress, the following
will not work out-of-the-box for you, but just for giggles, here's what the
template looks like:

    #syntax: perl
    package ContactSheet;

    use 5.10.0;

    use Moose;
    use Method::Signatures;

    use Template::Caribou::Utils;
    use Template::Caribou::Tags::HTML;

    with 'Template::Caribou';

    has root_url => (
        is => 'ro',
    );

    has shots => (
        traits => [ 'Array' ],
        is => 'ro', 
        default => sub { [] },
        handles => {
            all_shots => 'elements',
            add_shot => 'push',
        },
    );

    template 'main' => sub {
        my ($self) = @_;

        html {
            head {
                style {
                    say ::RAW q[
    body { 
        background: lightgrey;
    }

    div { 
        width: 300px;
        margin: 10px;
        display: inline-block;
        vertical-align: top;
        text-align: center;
    }

    ];
                }
            };
            body {
                show( 'shoot', @$_ ) for $self->all_shots;
            }
        };

    };

    template 'shoot' => method ( $url, $screen, $thumb ) {
        div {
            div {
                anchor $self->root_url . "/$url" => sub {
                    $url;
                }

            };
            anchor $screen => sub {
                image $thumb, sub { };
            };
        }
    };


## Step 6. Putting it together

And we are done. We assemble the different parts together in the script
'`website_contactsheet.pl`':

    #syntax: perl
    #!/usr/bin/env perl 

    use 5.10.0;

    use strict;
    use warnings;

    use Test::More;
    use Test::WWW::Mechanize;
    use Test::WWW::Selenium;
    use Path::Class qw/ file /;
    use GD::Image;

    use lib '.';
    use ContactSheet;

    my $root_url = shift or die;

    my $mech = Test::WWW::Mechanize->new;

    $mech->get_ok( "$root_url/sitemap" );

    my @links = $mech->links;

    my $sel = Test::WWW::Selenium->new( 
        host => "localhost",
        port => 4444,
        browser => "*firefox",
        browser_url => $root_url,
    );

    $sel->start;

    my $template = ContactSheet->new( root_url => $root_url );

    for my $url ( map { $_->url } @links ) {
        # selenium doesn't like the .xml for some reason
        next if $url eq '/sitemap.xml';

        $sel->open_ok( $url ) or next;

        ( my $screenshot_file = $url . ".png" ) =~ s#/#_#g;

        # Selenium wants an absolute path
        $sel->capture_entire_page_screenshot( file( $screenshot_file )->absolute );

        my $screenshot = GD::Image->newFromPng( $screenshot_file );
        my ( $width, $height ) = $screenshot->getBounds;
        my $scale = 300 / $width;

        my $thumbnail = GD::Image->new( 300, $scale * $height );
        $thumbnail->copyResampled($screenshot, ( 0 ) x 4, 
            300, $scale * $height,
            $width, $height, 
        );

        ( my $thumbfile  = $screenshot_file ) =~ s/(?=\.png)/_thumbnail/;
        print { file( $thumbfile )->openw } $thumbnail->png;

        $template->add_shot( [ $url, $screenshot_file, $thumbfile ] );
    }

    $sel->stop;

    diag "creating index file";

    print { file('index.html')->openw }
        $template->render('main');

    done_testing;

Run it:

    #syntax: bash
    $ ./website_contactsheet.pl http://enkidu:3000
    ok 1 - GET http://enkidu:3000/sitemap
    ok 2 - open, /
    ok 3 - open, /albums
    ok 4 - open, /feeds/acp.atom
    ok 5 - open, /magasin
    ok 6 - open, /magasin/panier
    ok 7 - open, /magasin/paypal/confirmation
    ok 8 - open, /magasin/paypal/retour
    ok 9 - open, /primes
    ok 10 - open, /primes/chienbine
    ok 11 - open, /primes/figurines
    ok 12 - open, /primes/icones
    ok 13 - open, /rentree
    ok 14 - open, /sitemap
    # creating index file
    1..14

*Et voilà.* 

<div align="center">
<img src="__ENTRY_DIR__/screenshot.png" width="600" /></div>

We now have a contact sheet where I can see at a glance... that I
still have a lot of work to do. \*sigh\*

