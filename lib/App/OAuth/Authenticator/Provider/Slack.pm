package App::OAuth::Authenticator::Provider::Slack;

use strict;
use warnings FATAL => 'all';

use Moo;

=head2 auth_uri

The authentication endpoint for the provider.

=cut

has auth_uri => (
    is       => 'ro',
    #init_arg => undef,
    coerce   => sub { URI->new($_[0]) if $_[0] },
    default  => sub { URI->new('https://slack.com/oauth/authorize') },
);

=head2 token_uri

The token endpoint for the provider.

=cut

has token_uri => (
    is       => 'ro',
    #init_arg => undef,
    coerce   => sub { URI->new($_[0]) if $_[0] },
    default  => sub { URI->new('https://slack.com/api/oauth.access') },
);

=head2 scope

Authorization scopes to request for this provider.

=cut

has scope => (
    is       => 'ro',
    #init_arg => undef,
    coerce   => sub { my $x = shift; ref $x ? $x : [split /\s+/, $x] if $x },
    default  => sub { [qw(team.read)] },
);

# consume the roles after we define these attributes since `has` is a
# thing that runs at ordinary runtime.
with qw(App::OAuth::Authenticator::Provider App::OAuth::Authenticator::OAuth2);

=head2 resolve_principal $TOKEN

=cut

sub resolve_principal {
}

# need the `team.read` scope which only operates on `team.info`

# here is some sample output

# {
#     "ok": true,
#     "team": {
#         "id": "T6MG2H85D",
#         "name": "Babytown Frolics",
#         "domain": "babytownyvr",
#         "email_domain": "",
#         "icon": {
#             "image_34": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_34.png",
#             "image_44": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_44.png",
#             "image_68": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_68.png",
#             "image_88": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_88.png",
#             "image_102": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_102.png",
#             "image_132": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_132.png",
#             "image_230": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_230.png",
#             "image_original": "https:\/\/slack-files2.s3-us-west-2.amazonaws.com\/avatars\/2017-08-09\/224520193940_2a1438a2c9067da691e1_original.png"
#         }
#     }
# }

# need `identity.basic` and `identity.email` to get `users.identity`

1;
