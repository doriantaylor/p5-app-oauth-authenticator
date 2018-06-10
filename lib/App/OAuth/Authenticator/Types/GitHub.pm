package App::OAuth::Authenticator::Types::GitHub;

use strict;
use warnings FATAL => 'all';

use Type::Library -base,
    -declare => qw(GitHubUser GitHubEmails GitHubOrg GitHubOrgs);
use Type::Utils -all;
use Types::Standard qw(slurpy Any Defined Maybe Optional
                       Str Dict ArrayRef HashRef);
use Types::XSD qw(Boolean PositiveInteger NonNegativeInteger
                  Token Base64Binary DateTime);
use App::OAuth::Authenticator::Types qw(MaybeBool MaybeToken
                                        URIRef MaybeURIRef Email MaybeEmail);

=head2 GitHubUser

Validates the response to C</user>.

=cut

declare GitHubUser, as Dict[
    login               => Token,
    id                  => PositiveInteger,
    node_id             => Base64Binary,
    avatar_url          => URIRef,
    gravatar_id         => MaybeToken,
    url                 => URIRef,
    html_url            => URIRef,
    followers_url       => URIRef,
    following_url       => URIRef,
    gists_url           => URIRef,
    starred_url         => URIRef,
    subscriptions_url   => URIRef,
    organizations_url   => URIRef,
    repos_url           => URIRef,
    events_url          => URIRef,
    received_events_url => URIRef,
    type                => Token,
    site_admin          => Boolean,
    name                => Token,
    company             => MaybeToken,
    blog                => MaybeURIRef,
    location            => MaybeToken,
    email               => MaybeEmail,
    hireable            => MaybeBool,
    bio                 => Maybe[Str],
    public_repos        => NonNegativeInteger,
    public_gists        => NonNegativeInteger,
    followers           => NonNegativeInteger,
    following           => NonNegativeInteger,
    created_at          => DateTime,
    updated_at          => Optional[DateTime],
    total_private_repos => Optional[NonNegativeInteger],
    owned_private_repos => Optional[NonNegativeInteger],
    private_gists       => Optional[NonNegativeInteger],
    disk_usage          => Optional[NonNegativeInteger],
    collaborators       => Optional[NonNegativeInteger],
    two_factor_authentication => Optional[Boolean],
    plan => Optional[Dict[
        name          => Token,
        space         => NonNegativeInteger,
        private_repos => NonNegativeInteger,
        collaborators => NonNegativeInteger,
        slurpy Any]],
    slurpy Any], coercion => 1;

=head2 GitHubEmails

Validates the response to C</user/email>.

=cut

declare GitHubEmails, as ArrayRef[Dict[
    email      => Email,
    verified   => Boolean,
    primary    => Boolean,
    visibility => Token,
    slurpy Any]], coercion => 1;

=head2 GitHubOrg

Validates the response to C</orgs/whatever>.

=cut

declare GitHubOrg, as Dict[
    login              => Token,
    id                 => PositiveInteger,
    node_id            => Base64Binary,
    url                => URIRef,
    repos_url          => URIRef,
    events_url         => URIRef,
    hooks_url          => URIRef,
    issues_url         => URIRef,
    members_url        => URIRef,
    public_members_url => URIRef,
    avatar_url         => URIRef,
    description        => Maybe[Str],
    name               => Token,
    company            => MaybeToken,
    blog               => MaybeURIRef,
    location           => MaybeToken,
    email              => MaybeEmail,
    has_organization_projects => Boolean,
    has_repository_projects   => Boolean,
    public_repos => NonNegativeInteger,
    public_gists => NonNegativeInteger,
    followers    => NonNegativeInteger,
    following    => NonNegativeInteger,
    html_url     => URIRef,
    created_at   => DateTime,
    updated_at   => Optional[DateTime],
    type         => Token,
    total_private_repos => Optional[NonNegativeInteger],
    owned_private_repos => Optional[NonNegativeInteger],
    private_gists       => Optional[NonNegativeInteger],
    disk_usage          => Optional[NonNegativeInteger],
    collaborators       => Optional[NonNegativeInteger],
    billing_email       => Optional[MaybeEmail],
    plan => Optional[Dict[
        name          => Token,
        space         => NonNegativeInteger,
        private_repos => NonNegativeInteger,
        slurpy Any]],
    default_repository_settings     => Optional[Token],
    members_can_create_repositories => Optional[Boolean],
    two_factor_requirement_enabled  => Optional[Boolean],
slurpy Any], coercion => 1;

=head2 GitHubOrgs

Validates the response to C</user/orgs>.

=cut

declare GitHubOrgs, as ArrayRef[Dict[
    login              => Token,
    id                 => PositiveInteger,
    node_id            => Base64Binary,
    url                => URIRef,
    repos_url          => URIRef,
    events_url         => URIRef,
    hooks_url          => URIRef,
    issues_url         => URIRef,
    members_url        => URIRef,
    public_members_url => URIRef,
    avatar_url         => URIRef,
    description        => Maybe[Str],
    slurpy Any]], coercion => 1;

1;
