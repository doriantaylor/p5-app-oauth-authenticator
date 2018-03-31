package App::OAuth::Authenticator::Provider::GitHub;

use strict;
use warnings FATAL => 'all';

use Moo;
use Try::Tiny;

use constant HDR => [[Accept => 'application/vnd.github.v3+json']];

# The following attributes are hard-coded from last-known values, but
# they can be overridden by config.

=head2 auth_uri

The authentication endpoint for the provider.

=cut

has auth_uri => (
    is       => 'ro',
    #init_arg => undef,
    default  => sub {},
);

=head2 token_uri

The token endpoint for the provider.

=cut

has token_uri => (
    is       => 'ro',
    #init_arg => undef,
    default  => sub {},
);

=head2 scope

Authorization scopes to request for this provider.

=cut

has scope => (
    is       => 'ro',
    #init_arg => undef,
    default  => sub {},
);

# consume the roles after we define these attributes since `has` is a
# thing that runs at ordinary runtime.
with qw(App::OAuth::Authenticator::Provider App::OAuth::Authenticator::OAuth2);

=head2 resolve_principal $TOKEN

Given an access token, retrieve the principal or return C<undef>. If
successful, update the entry in the state database.

May croak if there is a failure in the interaction with the provider's
API.

=cut

sub resolve_principal {
    my ($self, $token) = @_;

    # obtain a session with the token
    my $session = $self->get_session(token => $token);

    # do whatever API-specific thing is necessary here to resolve the
    # principal:
    my $principal;

    # these are just regular HTTP::Response objects coming out of this thing
    my $call = $session->get('https://api.github.com/user', HDR);
    if ($call->is_success and $call->content_type =~ /json/i) {
        # basic user info
        my $struct = $self->json->decode($call->content);

        #if $struct->{}
    }
    else {
        # do something like blow up with the error response
    }

    # save the token
    $self->app->state->token_for($principal, $token);

    $principal;
}

# match user


# by email (verified by github),

# ?s foaf:mbox ?verified

# and by membership to org

# either  ?s org:memberOf|org:headOf|^org:hasMember|^foaf:member ?org .
# or      ?s (^org:membership|org:member)/org:organization ?org .
# and     ?org (org:memberOf|org:headOf|^org:hasMember|^foaf:member)* ?origin .
# then    ?org foaf:account ?acct .
# and     ?acct foaf:accountServiceHomepage <https://github.com/> .
# finally ?org foaf:account ?acct


# get additional intel from the provider

1;
