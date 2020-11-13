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
