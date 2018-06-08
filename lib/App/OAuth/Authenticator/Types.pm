package App::OAuth::Authenticator::Types;

use strict;
use warnings FATAL => 'all';

use URI;

use Type::Library -base,
    -declare => qw(MaybeBool MaybeToken URIRef MaybeURIRef Email MaybeEmail
                   GitHubUser GitHubEmail GitHubOrg);
use Types::Standard qw(slurpy Any Defined Maybe Optional
                       Str Dict ArrayRef HashRef);
use Type::Utils -all;
use Types::XSD  -all;

coerce Boolean, from Defined, via { int $_ };
subtype MaybeBool, as Maybe[Boolean];
coerce MaybeBool, from Defined, via { int $_ };

sub _coerce_token {
    s/^\s*(.*?)\s*$/$1/sm;
    s/\s+//sm;
    $_;
}

subtype MaybeToken, as Maybe[Token];
coerce Token,      from Str, via \&_coerce_token;
coerce MaybeToken, from Str, via \&_coerce_token;

class_type URIRef, { class => 'URI' };
subtype MaybeURIRef, as Maybe[URIRef];

subtype Email, as URIRef,
    where { $_->can('scheme') and lc($_->scheme) eq 'mailto' };
subtype MaybeEmail, as Maybe[Email];

sub _coerce_email {
    my $em = to_Token($_);
    $em =~ s/^(mailto:)?(.*?)$/mailto:$2/i;
    URI->new($em);
}

coerce Email,      from Defined, via \&_coerce_email;
coerce MaybeEmail, from Defined, via \&_coerce_email;

sub _coerce_uri {
    $_ =~ s/^\s*(.*?)\s*$/$1/sm;
    URI->new($_);
}

coerce MaybeURIRef, from Defined, via \&_coerce_uri;
#    via { $_ =~ s/^\s*(.*?)\s*$/$1/sm; URI->new($_) };
coerce URIRef, from Defined, via \&_coerce_uri;
#    via { $_ =~ s/^\s*(.*?)\s*$/$1/sm; URI->new($_) };

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
    updated_at          => DateTime,
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
        slurpy HashRef]],
    slurpy HashRef], coercion => 1;

declare GitHubEmail, as ArrayRef[Dict[
    email      => Email,
    verified   => Boolean,
    primary    => Boolean,
    visibility => Token,
]], coercion => 1;

declare GitHubOrg, as Dict[
];

1;
