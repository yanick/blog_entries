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
