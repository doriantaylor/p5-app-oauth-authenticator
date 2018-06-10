package App::OAuth::Authenticator::Provider;

use strict;
use feature 'state';
use warnings FATAL => 'all';

use JSON;
use RDF::Query;

use UUID::URandom      ();
use Data::UUID::NCName ();

use Type::Params    qw(Invocant);
use Types::Standard qw(slurpy Any Dict Optional);
use Types::XSD      qw(Token);

use App::OAuth::Authenticator::Error;
use App::OAuth::Authenticator::Types qw(Type URIRef
                                        HTTPMethod HTTPHeaders HTTPRequest);

use Try::Tiny;
use Moo::Role;

# for now, only get_session and resolve_principal
requires qw(get_session resolve_principal);

=head2 app

This is a backreference to the application, passed in by the constructor.

=cut

has app => (
    is       => 'rwp',
    required => 1,
    weak_ref => 1,
);

=head2 json

A handy JSON parser/serializer.

=cut

has json => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { JSON->new },
);

=head2 label

A text label for the provider.

=cut

has label => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $class = ref $_[0];
        my ($label) = ($class =~ /^(?:.*::)?(.+?)$/);

        $label;
    },
);

=head2 state

Unique state token for resolving the provider in the OAuth response.

=cut

has state => (
    is => 'ro',
    default => sub {
        my $uuid = UUID::URandom::create_uuid();
        lc Data::UUID::NCName::to_ncname($uuid, 32);
    },
);

=head2 api_request

=over 4

=item token

OAuth access token

=item uri

=item method

=item headers

=item body

=item request

=back

=cut

my @PARSERS = (
    [qr/json/i => sub {
         my ($self, $payload) = @_;
         $self->json->decode($payload);
     }],
);

sub _check_parser {
    my $ct = shift;
    for my $pair (@PARSERS) {
        next unless $ct =~ $pair->[0];
        return $pair->[1];
    }
}

sub api_request {
    # this is kind of an experiment
    state $check = Type::Params::compile(
        Invocant, slurpy Dict[
            token   => Token,
            uri     => Optional[URIRef],
            method  => Optional[HTTPMethod],
            headers => Optional[HTTPHeaders],
            body    => Optional[Any],
            request => Optional[HTTPRequest],
            spec    => Optional[Type],
        ]);

    my ($self, $p) = $check->(@_);
    $p->{method} ||= 'GET';

    my $resp = $self->_proxy_request($p);

    # dump if the request is not successful
    unless ($resp->is_success) {
        warn $resp->as_string;
        warn "\n#####\n";
        warn $resp->request->as_string;
        my $code = int $resp->code;
        App::OAuth::Authenticator::Error::Server->throw(
            object => $resp, message => 'API returned 5XX error',
        ) if $code >= 500;
        App::OAuth::Authenticator::Error::Client->throw(
            object => $resp, message => 'API returned 4XX error',
        ) if $code >= 400;
        App::OAuth::Authenticator::Error::Network->throw(
            object => $resp, message => 'API returned some other status code',
        );
    }

    # now we check the content type for a parser
    my $parser = _check_parser($resp->content_type)
        or App::OAuth::Authenticator::Error::Network->throw(
            object => $resp, message => 'No parser for ' . $resp->content_type,
        );

    # now we parse the response
    my $obj;
    try { $obj = $parser->($self, $resp->content) } catch {
        # wrap the error and rethrow
        warn $resp->content;
        App::OAuth::Authenticator::Error::Parsing->throw(
            object => $_, message => 'Error parsing ' . $resp->content_type);
    };

    require Data::Dumper;
    warn Data::Dumper::Dumper($obj);

    # now we assert the spec
    if (my $type = $p->{spec}) {
        if (my $c = $type->coercion) {
            my $tmp;
            try { $tmp = $c->assert_coerce($obj) } catch {
                App::OAuth::Authenticator::Error::Validation->throw(
                    object  => $obj,
                    message => "Could not coerce API response to $type: $_");
            };
            $obj = $tmp;
        }
        else {
            App::OAuth::Authenticator::Error::Validation->throw(
                object  => $obj,
                message => "API response failed to validate against $type: " .
                    join("\n", @{$type->validate_explain($obj, '$obj')}))
                  unless $type->check($obj);
        }
    }

    $obj;
}

1;
