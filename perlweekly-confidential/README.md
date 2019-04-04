---
url: perlweekly-confidential
created: 2014-07-26
tags:
    - Perl
    - PerlWeekly
---

# Perlweekly Confidential: Corralling News

This one is straight up from *the Chronicles of a Lazy Man*. As you might know,
I'm a co-editor of the [PerlWeekly](http://www.perlweekly.com). Part of the
job is to curate the articles, and write blurbs about it. Another part is the
aggregating of those articles in the JSON document that will be used to
generate the email and webpage. As you might guess, the former is all fun and
games, while the latter is... not so much.

As documented in a [previous blog entry](http://techblog.babyl.ca/entry/vim-x-update), I already eased the pain of the
clerk work by using a Markdown-ish format, and having Perl figure out the
title and date of publication of the articles from the url. Which is already
quite nice. But I began to think... Those articles, they come mostly from
blogs, right? And blogs, they mostly do have RSS feeds, right? And those
feeds, they mostly do have all the metadata (title, dates, author) I'm looking
for, right? So... why am I doing all that work?

Yes, dear friends, I wasn't being lazy enough. And that wouldn't do.

## Gathering articles from RSS feeds

So what I did was to create a simple rss feed file, with one feed per line.
Something like

```
http://blogs.perl.org/atom.xml
http://ironman.enlightenedperl.org/?feed=atom
# http://techblog.babyl.ca/feed/atom
http://neilb.org/atom.xml
http://www.yapceurope.org/feeds/news.rss
```

With that as my source of information, I then rolled up my 
sleeves and began to write my script.


First, I needed to read the lines, skipping over the commented out ones.

``` perl
my @feeds = map { s/\s.*$//r; } grep { /^[^#]/ and not /^\s*$/ } <>;
chomp @feeds;
```

Then, because the PerlWeekly always reports what happened the week before, I
preemptively found out what was the cut-off date for this edition.

``` perl
use DateTime::Functions qw/ today /;

my $cutout_date = today();

# find out last Monday
$cutout_date->subtract( days => 1) until $cutout_date->day_of_week == 1;
```

With that, I'm ready to read and filter all those feeds.

``` perl
use XML::Feed;
use URI;

my %seen;

my @entries = 
    sort { $a->issued <=> $b->issued        }
    grep { not $seen{ $_->link }++          } # skip dupes
    grep { $_->issued >= $cutout_date       } # recent enough?
    map  { $_->entries                      } # get all its entries
    map  { XML::Feed->parse( URI->new($_) ) } # get the feed
    @feeds;
```

The brunt of the work here is done by [XML::Feed](cpan:release/XML-Feed),
which doesn't only fetch and parse the blog entries for us, but also 
transparently deal with both RSS and atom formats.

Now that we have the nicely deduped articles, all that remains to do is to
write them out in as stub entries in the Markdown-like format I use.

``` perl
for my $entry ( @entries ) {
    say '### ', $entry->title;
    say $entry->link;
    say eval { $entry->issued->ymd } || '????-??-??';
    say "\n", $entry->author, "\n";
}
```

And there we go. Less than 30 lines of code to take care of most of
the data gathering drudgery.

## Gathering RSS feeds from articles

Most sane persons would have stopped there. Me, I began to think...
So now I have to gather the urls of the RSS feeds I want to harvest, right?
But we have lots of sites we feature over and over again, right? So we already
have urls pointing to those sites, don't we? So if we could revisit those
sites, and figure out if they have a rss url...

And that's where XML::Feed's wonderful `find_feeds()` enter the picture. So,
again, I open my editor and begin to write an itsy-bitsy script...

First, I get the location of the feed file and the PerlWeekly document I want
to use.

``` perl
use Path::Tiny qw/ path /;

my( $feeds_file, $week_file ) = map { path($_) } @ARGV;
```

From the PerlWeekly's file, I extract all articles' urls.

``` perl
use JSON::Path;

my $json = $week_file->slurp;

my $jpath = JSON::Path->new( '$.chapters[*].entries[*].url' );

my @urls = map { URI->new($_) } $jpath->values($json);
```

I establish a list of sites we already know about from the already-recorded
rss feeds.

``` perl
use URI;

my %already_seen;

for ( $feeds_file->lines ) {
    chomp;
    s/\s*#//;
    s/\s.*$//;
    next if /^\s*$/;
    $already_seen{ URI->new($_)->host }++;
}
```

Then I let `XML::Feed` try to discover the new feeds, and append them to
the feed file.

``` perl
use XML::Feed;

for my $url ( @urls ) {
    next if $already_seen{ $url->host }++;

    for my $feed ( XML::Feed->find_feeds($url) ) {
        warn "adding $feed\n";
        $feeds_file->append( "$feed\n" );
    }

}
```

And, again, we are done. Our database of monitored sites can now grow and be
harvested with a minimum of effort, and I can now focus on the important
stuff. Namely: write snarky blurbs for all those articles.
