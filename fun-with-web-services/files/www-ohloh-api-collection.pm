package WWW::Ohloh::API::Collection;

use Moose::Role;

use Carp;

with 'WWW::Ohloh::API::Role::Fetchable' => { -excludes => 'fetch' };

has entry_class => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { die "'entry_class must be defaulted\n" },
);

has cached_entries => (
    traits  => ['Array'],
    isa     => 'ArrayRef',
    is      => 'ro',
    default => sub { [] },
    handles => {
        add_entries     => 'push',
        cache_empty     => 'is_empty',
        cache_size      => 'count',
        next_from_cache => 'shift',
    },
);

after next_from_cache => sub { $_[0]->inc_entry_cursor };

has page_cursor => (
    is      => 'rw',
    traits  => ['Counter'],
    isa     => 'Int',
    default => 1,
    handles => { inc_page => 'inc', },
);

has entry_cursor => (
    is      => 'rw',
    traits  => ['Counter'],
    isa     => 'Int',
    default => 0,
    handles => { inc_entry_cursor => 'inc', },
);

has nbr_entries => (
    is        => 'rw',
    isa       => 'Int',
    predicate => 'has_nbr_entries',
    lazy      => 1,
    default   => sub {
        $_[0]->fetch->nbr_entries;
    },
);

sub fetch {
    my ( $self, @args ) = @_;

    # no more to fetch
    return
      if $self->has_nbr_entries 
         and $self->entry_cursor >= $self->nbr_entries;

    $self->clear_request_url;

    my $xml = $self->agent->_query_server( $self->request_url );

    $self->nbr_entries( $xml->findvalue('/response/items_available') );

    my @entries = $xml->findnodes('//result/child::*');
    my $first   = $xml->findvalue('/response/first_item_position');

    while ( @entries and $first < $self->entry_cursor ) {
        shift @entries;
        $first++;
    }

    $self->add_entries( $xml->findnodes('//result/child::*') );

    $self->inc_page;

    return $self;
}

sub all {
    my $self = shift;

    my @entries;

    while ( my $e = $self->next ) {
        push @entries, $e;
    }

    return @entries;
}

sub next {
    my $self = shift;

    return if $self->entry_cursor >= $self->nbr_entries;

    if ( $self->cache_empty ) {
        $self->fetch;
    }

    my $raw = $self->next_from_cache or return;

    return $self->entry_class->new(
        agent   => $self->agent,
        xml_src => $raw,
    );
}

around _build_request_url => sub {
    my ( $inner, $self ) = @_;

    my $uri = $inner->($self);

    my $params = $uri->query_form_hash;

    $params->{page} = $self->page_cursor;

    $uri->query_form_hash($params);

    return $uri;
};

1;

