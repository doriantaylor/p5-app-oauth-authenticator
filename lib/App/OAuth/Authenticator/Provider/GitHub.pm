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
    coerce   => sub { URI->new($_[0]) if $_[0] },
    default  => sub { URI->new('https://github.com/login/oauth/authorize') },
);

=head2 token_uri

The token endpoint for the provider.

=cut

has token_uri => (
    is       => 'ro',
    #init_arg => undef,
    coerce   => sub { URI->new($_[0]) if $_[0] },
    default  => sub { URI->new('https://github.com/login/oauth/access_token') },
);

=head2 scope

Authorization scopes to request for this provider.

=cut

has scope => (
    is       => 'ro',
    coerce   => sub { my $x = shift; ref $x ? $x : [split /\s+/, $x] if $x },
    default  => sub {[qw(read:user read:org user:email)]},
);

# consume the roles after we define these attributes since `has` is a
# thing that runs at ordinary runtime.
with qw(App::OAuth::Authenticator::Provider App::OAuth::Authenticator::OAuth2);

=head2 resolve_principal $TOKEN

Given an access token, retrieve the principal or return C<undef>. If
successful, update the entry in the state database.

May croak if there is a failure in the interaction with the provider's
API.

This method is intended to be called from the confirmation/validation target.

=cut

sub resolve_principal {
    my ($self, $token, $rules) = @_;

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

# try to get a principal out of the github user

# first let's see if the damn account is in the graph

# ?s (foaf:account|^sioc:account_of) ?account .

# no? okay let's try email (only those verified by github)

# ?s foaf:mbox ?verified .

# no? how about indirectly

# ?s (foaf:account|^sioc:account_of)/sioc:email ?verified .

# no? how about if the github page itself is listed in some way

# ?s ?p ?html_url .

# still no? how about matching on the 'blog' entry?

# ?s (foaf:page|foaf:homepage|foaf:weblog) ?blog .

# still no? how about the name i guess

# ?s (foaf:name|foaf:nickname) ?n . FILTER (UCASE(str(?n)) = UCASE(?nick))

# those are really the only handles we have for matching people to accounts


# if we don't have the account in the graph, we should probably add it

# whether or not we add a new person though? ...


# anyway, once we have the principal, we need to check that it is a
# member of the organization:

# either  ?s org:memberOf|org:headOf|^org:hasMember|^foaf:member ?org .
# or      ?s (^org:membership|org:member)/org:organization ?org .

# subsequently, we can test if the organization belongs to the origin

# ?org (org:memberOf|org:headOf|^org:hasMember|^foaf:member)* ?origin .

# so consider the 'member' verb in our own authentication lexicon: do
# we identify by proxy as well? consider:

# ?s foaf:account ?account .
# ?account (sioc:member_of|^sioc:has_member) ?group .
# ?group (sioc:usergroup_of|^sioc:has_usergroup) ?site .
# ?org (org:hasSite|^org:siteOf)/org:siteAddress? ?site .

# (then we match the org to the origin)

# another consideration is a function that enables provider
# administrators to import (e.g. account) data from the provider

# that is going to entail a whooooooole lotta UI

# ???

1;
