package WWW::Ohloh::API::Object::Account;

use Moose;

use MooseX::SemiAffordanceAccessor;

with 'WWW::Ohloh::API::Role::Fetchable';

use WWW::Ohloh::API::Types qw/ OhlohId OhlohDate OhlohURI /;

use Digest::MD5 qw/ md5_hex /;

has id => (
    traits => [ 'XMLExtract' ],
    is      => 'rw',
    isa     => 'Str',
    predicate => 'has_id',
);

has name => (
    traits => [ 'XMLExtract' ],
    is      => 'rw',
    isa     => 'Str',
    predicate => 'has_name',
);


has [qw/ created_at updated_at /] => (
    traits => [ 'XMLExtract' ],
    isa => OhlohDate,
    is => 'rw',
    coerce => 1,
);

has [ qw/homepage_url avatar_url/ ] => (
    traits => [ 'XMLExtract' ],
    is => 'rw',
    isa => OhlohURI,
    coerce => 1,
);

has posts_count => (
    traits => [ 'XMLExtract' ],
    is => 'rw',
    isa => 'Int',
);

has [qw/ location country_code /] => (
    traits => [ 'XMLExtract' ],
    is => 'rw',
    isa => 'Str',
);

has [ qw/ latitude longitude / ] => (
    traits => [ 'XMLExtract' ],
    is => 'rw',
    isa => 'Num',
);


has 'kudo_score' => (
    is => 'rw',
    isa => 'WWW::Ohloh::API::Object::KudoScore',
    lazy => 1,
    default => sub {
        my $self = shift;

        return WWW::Ohloh::API::Object::KudoScore->new(
            agent => $self->agent,
            xml_src => $self->xml_src->findnodes( 'kudo_score' )->[0],
        );
    },
);

has stack => (
    is => 'rw',
    isa => 'WWW::Ohloh::API::Object::Stack',
    lazy => 1,
    default => sub {
        my $self = shift;

        return WWW::Ohloh::API::Object::Stack->new(
            agent   => $self->agent,
            id      => $self->id,
            account => $self,
        );
    },
);

has email => (
    is      => 'rw',
    isa     => 'Str',
    lazy     => 1,
    default  => '',
    predicate => 'has_email',
);

has email_md5 => (
    is      => 'rw',
    isa     => 'Str',
    lazy     => 1,
    default => sub {
        md5_hex($_[0]->email);
    },
    predicate => 'has_email_md5',
);

around _build_request_url => sub {
    my( $inner, $self ) = @_;
    
    my $uri = $inner->($self);

    $self->has_id or $self->has_email or $self->has_email_md5
        or die "id or email not provided for account, cannot fetch";

    my $id = $self->has_id ? $self->id : $self->email_md5; 

    $uri->path( 'accounts/' . $id . '.xml' );

    return $uri;
};

1;

