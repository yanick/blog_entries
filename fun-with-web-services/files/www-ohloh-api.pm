package WWW::Ohloh::API;

use Carp;

use Moose;

use MooseX::SemiAffordanceAccessor;

use Module::Pluggable
  require     => 1,
  search_path => [qw/ 
    WWW::Ohloh::API::Object 
    WWW::Ohloh::API::Collection 
/];

use LWP::UserAgent;
use Readonly;
use XML::LibXML;
use List::Util qw/ first /;
use Digest::MD5 qw/ md5_hex /;

our $OHLOH_HOST = 'www.ohloh.net';
our $OHLOH_URL  = "http://$OHLOH_HOST";

our $useragent_signature = join '/', 'WWW-Ohloh-API',
  ( eval q{$VERSION} || 'dev' );

has api_key => ( is => 'rw', );

has api_version => (
    is      => 'rw',
    default => 1,
);

has user_agent => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->agent($useragent_signature);
        return $ua;
    } );

has xml_parser => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return XML::LibXML->new;
    } );

sub fetch {
    my ( $self, $object, @args ) = @_;

    my $class = first { /::$object$/ } $self->plugins
      or croak "object or collection '$object' not found";

    return $class->new( agent => $self, @args, )->fetch;
}

sub _query_server {
    my $self = shift;
    my $url  = shift;

    unless ( ref $url eq 'URI' ) {
        $url = URI->new($url);
    }

    my $result = $self->_fetch_object($url);

    my $dom = eval { $self->xml_parser->parse_string($result) }
      or croak "server didn't feed back valid xml: $@";

    if ( $dom->findvalue('/response/status/text()') ne 'success' ) {
        croak "query to Ohloh server failed: ",
          $dom->findvalue('/response/status/text()');
    }

    return $dom;
}

sub _fetch_object {
    my ( $self, $url ) = @_;

    my $request = HTTP::Request->new( GET => $url );
    my $response = $self->user_agent->request($request);

    unless ( $response->is_success ) {
        croak "http query to Ohloh server failed: " . $response->status_line;
    }

    return $response->content;
}

1;
