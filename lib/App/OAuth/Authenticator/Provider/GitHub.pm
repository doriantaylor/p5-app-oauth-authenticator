package App::OAuth::Authenticator::Provider::GitHub;

use strict;
use warnings FATAL => 'all';

use Moo;
use Try::Tiny;

# i would just embed this but ->import doesn't work like use does
use App::OAuth::Authenticator::Types::GitHub
    qw(GitHubUser GitHubEmails GitHubOrgs);

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

    # note that there are two moves here: one to identify the
    # principal, and another to check whether the principal belongs to
    # a given group (and only then if that's what the authorization
    # rule says to do).

    # there is a high probability that the *account* is not in our
    # database

    # there is a distinct possibility that the *principal* is also not
    # in our database

    # authenticating the principal goes in this order:

    # principal has github account X

    # principal has email address X

    # principal has blog/website address X (kind of degenerate)

    # (we hope this only matches one principal)

    # it may be useful to generate a new principal with information
    # found in the API responses

    # it also may be the case that the principal controls the account
    # and the account is part of the group account, but the principal
    # is not part of the group (even though we treat them like they
    # are, for the purpose of authentication/authorization).

    # so we can add the principal to the graph, add their account, and
    # even add the fact that the account is part of the group's
    # account, but we do not presume that the principal is part of the
    # group.

    # note as well that the kind of intel available to gather is going
    # to depend on the provider. github and slack, for instance, have
    # concepts of groups and/or organizations, where twitter, for
    # instance, does not.

    # do whatever provider-specific thing is necessary here to resolve
    # the principal:

    my $principal;

    # these calls either return objects or raise exceptions

    my $user = $self->api_request(
        token   => $token,
        uri     => 'https://api.github.com/user',
        spec    => GitHubUser,
        headers => HDR,
    );

    warn "look ma: " . Data::Dumper::Dumper($user);

    # okay we got the user, try to match:

    # * account address

    # * 'blog' entry

    my $email = $self->api_request(
        token   => $token,
        uri     => 'https://api.github.com/user/emails',
        spec    => GitHubEmails,
        headers => HDR,
    );

    warn "look ma: " . Data::Dumper::Dumper($email);

    my $orgs = $self->api_request(
        token   => $token,
        uri     => $user->{organizations_url},
        spec    => GitHubOrgs,
        headers => HDR,
    );

    warn "look ma: " . Data::Dumper::Dumper($orgs);

    $principal;
}

# try to get a principal out of the github user

# first let's see if the damn account is in the graph:

# ?s (foaf:account|^sioc:account_of) ?account .

# no? okay let's try email (only those verified by github):

# ?s foaf:mbox ?verified .

# no? how about indirectly:

# ?s (foaf:account|^sioc:account_of)/sioc:email ?verified .

# no? how about if the github page itself is listed in some way:

# ?s ?p ?html_url .

# still no? how about matching on the 'blog' entry?

# ?s (foaf:page|foaf:homepage|foaf:weblog) ?blog .

# still no? how about the name i guess:

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
