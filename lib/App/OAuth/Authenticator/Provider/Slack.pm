package App::OAuth::Authenticator::Provider::Slack;

use strict;
use warnings FATAL => 'all';

use Moo;

with 'App::OAuth::Authenticator::Provider';
with 'App::OAuth::Authenticator::OAuth2';


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
