use 5.10.0;

use strict;
use warnings;

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

# see which tickets we already have on the github side
my @gh_issues =
  map { /\(rt(\d+)\)/ } 
  map { $_->{title} }    
      @{ $gh->list('open') || [] };

say join ' ', 'github issues:', @gh_issues;

export_ticket( $_ ) for $rt->search(
    type  => 'ticket',
    query => qq{
        Queue = '$rt_dist' 
        and
        ( Status = 'new' or Status = 'open' )
    },
);

sub export_ticket {
    my $id = shift;

    say "ticket $id";

    return say "already on github" if $id ~~ @gh_issues;

    # get the information from RT
    my $ticket = RT::Client::REST::Ticket->new(
        rt => $rt,
        id => $id,
    );
    $ticket->retrieve;

    # we just want the first transaction, which
    # has the original ticket description
    my $desc = $ticket->transactions->get_iterator->()->content;

    # create the github ticket
    my $gh_ticket = $gh->open( $ticket->subject . ' (rt' . $_ . ')',
        "https://rt.cpan.org/Ticket/Display.html?id=$_\n\n" . $desc );

    # and assign it the label 'rt'
    $gh->add_label( $gh_ticket->{number} => 'rt', );
}
