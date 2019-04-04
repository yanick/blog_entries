---
title: Bandying tickets from RT to GitHub Issues
url: rt-to-github 
format: markdown
created: 2011-07-17
last_updated: 5 Mar 2013
tags:
    - Perl
    - RT
    - GitHub
    - RT::Client::REST
    - Net::GitHub
---

> **Update:** An updated script for v3 of the GitHub API can be found in my
> [environment
> repo](https://github.com/yanick/environment/blob/master/bin/rt-to-github.pl).
> An [alternate
> version](http://www.dagolden.com/index.php/1938/how-to-move-cpan-rt-tickets-to-github/)
> by David Golden also exists.

Don't you hate it when you're given the choice between a few tools, and all of them 
are real nifty, but are missing a (different) key feature?

Today, I had that tantalizing problem with bug tracking systems. As the new
maintainer of [DBD::Oracle](cpan), I'm trying to wrap my head around 
the [32 tickets currently open against it](https://rt.cpan.org/Dist/Display.html?Name=DBD-Oracle).
Many tickets are platform-dependent, or appear for a specific version of
Oracle. It would be fantastic to be able to tag the different tickets with
those details, but alas CPAN's RT doesn't have tags. Booh!

But... GitHub Issues have tags. Wonderful. Except that... as of now, GitHub
Issues doesn't support priorities. Hiss!

So it all boils down to what do I want most (or, on the flip side,
what I can live without), priorities or tags? Another factor, entropy, 
will probably make me keep RT as the official bug tracking system. 
But, migrating or not, I would still like to have a copy of my RT tickets 
on GitHub, just so that I can use the tags, and integrate the tickets
more tightly with the development flow.

Fortunately, with the help of [RT::Client::REST](cpan)
and [Net::GitHub](cpan), it's quite easy to export our tickets.

First, we create our github and rt clients:

<pre code="Perl">
use RT::Client::REST;
use RT::Client::REST::Ticket;

use Net::GitHub::V2::Issues;

my $github_user       = 'yanick';
my $github_token      = 'deadbeef';
my $github_repo_owner = 'yanick';
my $github_repo       = 'DBD-Oracle';

my $rt_user     = 'pythian';
my $rt_password = 'secret';
my $rt_dist     = 'DBD-Oracle';

my $gh = Net::GitHub::V2::Issues->new(
    owner => $github_repo_owner,
    repo  => $github_repo,
    login => $github_user,
    token => $github_token,
);

my $rt = RT::Client::REST->new( server => 'https://rt.cpan.org/' );
$rt->login(
    username => $rt_user,
    password => $rt_password
);
</pre>

We don't want to migrate tickets over and over again, so we look
at our github tickets, and see if they relate to rt tickets. 
To keep things simple, I'll make sure that tickets coming from
RT contain the ticker number in their title.

<pre code="Perl">
# see which tickets we already have on the github side
my @gh_issues =
  map { /\(rt(\d+)\)/ } 
  map { $_->{title} }    
      @{ $gh->list('open') || [] };

say join ' ', 'github issues:', @gh_issues;
</pre>

After that, we query RT for all the active tickets, and try to export them:

<pre code="Perl">
export_ticket( $_ ) for $rt->search(
    type  => 'ticket',
    query => qq{
        Queue = '$rt_dist' 
        and
        ( Status = 'new' or Status = 'open' )
    },
);
</pre>

The export function is pretty simple. As mentioned before, we
first check that the ticket doesn't already exist on the github
side:


<pre code="Perl">
sub export_ticket {
    my $id = shift;

    say "ticket $id";

    return say "already on github" if $id ~~ @gh_issues;
</pre>

If it doesn't, we import the main ticket information, plus
the description of the ticket (contained in its first
transaction):

<pre code="Perl">
    # get the information from RT
    my $ticket = RT::Client::REST::Ticket->new(
        rt => $rt,
        id => $id,
    );
    $ticket->retrieve;

    # we just want the first transaction, which
    # has the original ticket description
    my $desc = $ticket->transactions->get_iterator->()->content;
</pre>

Finally, we create the github issue with those pieces of 
data:

<pre code="Perl">
    # create the github ticket
    my $gh_ticket = $gh->open( $ticket->subject . ' (rt' . $_ . ')',
        "https://rt.cpan.org/Ticket/Display.html?id=$_\n\n" . $desc );

    # and assign it the label 'rt'
    $gh->add_label( $gh_ticket->{number} => 'rt', );
}
</pre>

The full script is available [here](__ENTRY_DIR__/rt-to-github.pl).

And that's all there is to it. It's simple, but it gets the job
[done](https://github.com/yanick/DBD-Oracle/issues).  

