package App::OAuth::Authenticator::OAuth2;

use strict;
use warnings FATAL => 'all';

# XXX note the OAuth2 module is kind of a friggin mess and I may do
# away with it entirely and just bareback my own implementation, as
# OAuth2 doesn't have any crypto stuff in it like OAuth 1 does.

use Net::OAuth2::AccessToken;
use Net::OAuth2::Profile::WebServer;
use Throwable::Error;

use Moo::Role;

=head1 NAME

App::OAuth::Authenticator::OAuth2 - Role encapsulating OAuth 2.0

=cut

=head2 ua

The OAuth2 user agent (actually a misnomer; the UA is buried in that
object somewhere but whatever).

=cut

has ua => (
    is       => 'ro',
    init_arg => undef,
    lazy     => 1,
    default  => sub {
        my $self = shift;
        Net::OAuth2::Profile::WebServer->new(
            client_id        => $self->id,
            client_secret    => $self->secret,
            authorize_url    => $self->auth_uri,
            access_token_url => $self->token_uri,
            scope            => $self->scope,
        );
    },
);

# again add `with` after we're through with all the `has`
with 'App::OAuth::Authenticator::Generic';

sub _wrap_auth_uri {
    my $self = shift;
    $self->ua->authorize(@_);
}

=head2 get_session %PARAMS

Obtain an object that is suitable for making API calls. Keys not on
this list will be passed into the L<Net::OAuth2::AccessToken>
constructor. Note these keys are mutually exclusive:

=over 4

=item code

Given a C<code> emanating from an OAuth 2 authorization response, this
method will attempt to acquire an access token. This version of
the method call may raise an exception if the authentication fails.

=item token

Given a known access C<token>, this will return the same result as
if given a C<code>, of course without the network round-trip.

=back

=cut

sub get_session {
    my $self = shift;
    my %p = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    my $profile = $self->ua;

    if (my $code = delete $p{code}) {
        # XXX try to figure out what happens if this does not return
        # successfully
        return $profile->get_access_token($code);
    }
    elsif (my $token = delete $p{token}) {
        # XXX not sure why i can't just do this within the profile API
        return Net::OAuth2::AccessToken->new(
            profile      => $profile,
            auto_refresh => !!$profile->auto_save,
            %p, # do extra params before the token
            access_token => $token, # do this last
        );
    }
    else {
        Throwable::Error->throw(
            'Need either an access token, or a code with which to obtain one.');
    }
}

1;
