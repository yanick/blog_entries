---
title: From the Blogs to Your Mailbox
url: mailfeed
format: markdown
created: 2012-02-18
tags:
    - Perl
    - Blogs
    - RSS
---

There is an universal rule that all application almost, *almost* do what
you want, but not quite. For regular users, it's horripilating. For hackers,
it's a tantalizing torment as our breed usually have more hubris in stock
than we have tuits.

The itch of today is RSS readers. For the last few years, I've
been used [Akregator](http://kde.org/applications/internet/akregator/), and I'm pretty satisfied with it.
But there a few features I would like to have access to, but I don't. Namely:

* Be able to access the feeds from any of my machines, not just the local one.

* Filter out the duplicate entries that I get from [Perl Ironman](http://ironman.enlightenedperl.org/),
[Perlsphere](http://perlsphere.net/) and the individual blogs I'm following.

So I thought: what if I found a way to get the blog entries, and plop them on
mailboxes on my mail server? That would take care of ubiquitous access. And
since I would have control on the software, I could probably manage to filter
out dupes.

So yesterday I sat down and began to hack on this. The result is 
[mailfeed](https://github.com/yanick/mailfeed) (clever project name
pending).  I'm still not sure if it's a good idea, but at least its execution
showcase how much niftiness can be crammed within 144 lines of code.

But let me show you...

## General Framework

As I don't have a lot of time to throw at this problem, I don't want to
struggle very long with configurations and setting up the thing. So I decided
to go with a simple yaml configuration file:

    #syntax: plain
    app_dir: /home/yanick/work/feed2mail
    feeds:
        - "fearful symmetry": http://babyl.ca/techblog/atom.xml
        - "ironman": http://ironman.enlightenedperl.org/?feed=atom

and then let [MooseX::ConfigFromFile](cpan) take care of the rest:

    #syntax: perl
    package App::MailFeed;

    use YAML::Syck qw/ LoadFile /;

    use Moose;

    with qw/ MooseX::ConfigFromFile /;

    has feeds => (
        traits  => ['Array'],
        is => 'ro',
        handles => {
            all_feeds => 'elements',
        },
    );

    has app_dir => (
        is => 'ro',
        required => 1,
    );

    sub get_config_from_file { LoadFile( $_[1] ) }


Okay, we have our backbone. Now we can begin to play.

## Let's Have Some Persistance

Actually, before we begin to play for real, we need another 
framework piece to store information between runs, so that
we don't reimport blog entries over and over again. 
[CHI](cpan) is perfect for that, and since we want
to begin small, [CHI::Driver::BerkeleyDB](cpan) should
be Good Enough(tm) to begin with.

    #syntax: perl
    has cache => (
        lazy => 1,
        default => sub {
            CHI->new( 
                driver => 'BerkeleyDB',
                root_dir => $_[0]->app_dir,
            );
        },
        handles => {
            set_cache => 'set',
            cached => 'get',
        },
    );

## Visiting the Feeds

At a high level, this is easily done:

    #syntax: perl
    method import_feeds {
        $self->import_feed( %$_ ) for $self->all_feeds;
    }

The import itself is better left to the professional: [XML::Feed](cpan). 
Not only it does all the hard work for us, but it groks both RSS and Atom
formats, so we don't even have to worry about that. 

    #syntax: perl
    method import_feed( $name, $url ) {
      $self->log_debug( "importing feed $name" );

      my $feed = XML::Feed->parse( URI->new($url ) ) 
        or return $self->log_debug( "couldn't parse feed at '$url'" );

      $self->import_feed_entry( $name => $_ ) 
        for $feed->entries;
    }

That works. But it's kinda wasteful to always get the whole feed. We might
want to add a check that the feed was actually modified since the last run:

    #syntax: perl
    use LWP::Simple qw/ head /;

    method import_feed( $name, $url ) {
        $self->log_debug( "importing feed $name" );

        my $feed_key = "feed:$url";

        my $feed_modified = $self->feed_last_modified( $url );

        if( my $last_cache = $self->cached($feed_key) ) {
        if( $last_cache == $feed_modified ) {
            $self->log_debug( "feed hasn't been updated, skipping" );
            return;
        }
        }

        my $feed = XML::Feed->parse( URI->new($url ) ) or do {
        $self->log_debug( "couldn't parse feed at '$url'" );
        return;
        };

        $self->import_feed_entry( $name => $_ ) for $feed->entries;

        $self->set_cache( $feed_key => $feed_modified ) if $feed_modified;
    }

    method feed_last_modified( $url ) { (head($url))[2] }

There. Much more civilized.

## Transmuting Feed Entries to Mails

Generating emails, and interacting with mailboxes are hard tasks. 
Thanks to [Email::MIME](cpan) and [Email::LocalDelivery](cpan),
however, that's not my problem. `Email::LocalDelivery`, incidentally,
is good enough to deal with maildir and mbox-type mailboxes with equal ease.

    #syntax: perl
    method import_feed_entry ( $name, $entry ) {
        $self->log_debug( "processing " . $entry->title );

        my $link = $entry->link;

        if( $self->cached( $link ) ) {
            $self->log_debug( "entry already seen, skipping" );
            return;
        }

        my $email = $self->entry_to_email( $entry );

        Email::LocalDelivery->deliver( $email => $name );

        $self->set_cache( $link => time );
    }

The cache, bless its little heart, is preventing multiple imports
of the same blog entries. The thing it doesn't take care of (yet)
is recognizing urls that are not identical, but resolve to the same
page (`http://babyl.ca/techblog/entry/foo` and
`http://babyl.ca/techblog/entry/foo?display=print`, for example).
That's something that might be dealt with in the future by a set of
user-provided url filters.

And with this, only the actual conversion from feed entry to mail is left to be done:

    #syntax: perl
    method entry_to_email( $entry ) {
        my $link = $entry->link;
        
        $link = "<a href='$link'>$link</a><br/><br/>" 
        if $entry->content->type eq 'text/html';

        return Email::MIME->create(
        header => [
            From  => sprintf( 'dummy@foo.org <%s>', 
                            $entry->author || ''),
            To    => 'dummy@foo.org',
            Subject => $entry->title,
            ],
            parts => [
            Email::MIME->create(
                attributes => { 
                    content_type => $entry->content->type 
                },
                body => join "\n\n", 
                            $link, $entry->content->body,
            ),
            ],
        )->as_string;
    }

## Feed Me!

And that's it. We put all our pieces together, and...

    #syntax: bash
    $ perl mailfeed.pl feeds.yml                                                                                      
    [26809] importing feed fearful symmetry
    [26809] processing Cross-breeding Template::Declare with Moose
    [26809] processing Deploying Stuff With Git
    [..]
    [26809] importing feed ironman
    [26809] processing Pradeep Pant: Resource on debugging, profiling and benchmarking in Perl
    [26809] processing geistteufel: SlidesShow - HTML5
    [26809] processing YAPC::EU 2012: Video Recordings for YAPC::Europe 2012
    [26809] processing John Wang: Base58: Fast Hashing with GMP
    [26809] processing Jamadam: PogoPlugでウェブサーバー
    [..]

    $ perl mailfeed.pl feeds.yml                                                                                      
    [26848] importing feed fearful symmetry
    [26848] feed hasn't been updated, skipping
    [26848] importing feed ironman
    [26848] processing Pradeep Pant: Resource on debugging, profiling and benchmarking in Perl
    [26848] entry already seen, skipping
    [26848] processing geistteufel: SlidesShow - HTML5
    [26848] entry already seen, skipping
    [26848] processing YAPC::EU 2012: Video Recordings for YAPC::Europe 2012
    [26848] entry already seen, skipping
    [26848] processing John Wang: Base58: Fast Hashing with GMP
    [26848] entry already seen, skipping
    [26848] processing Jamadam: PogoPlugでウェブサーバー
    [26848] entry already seen, skipping
    [..]
