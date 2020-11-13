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
