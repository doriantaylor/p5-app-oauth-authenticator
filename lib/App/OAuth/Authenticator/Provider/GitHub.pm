package App::OAuth::Authenticator::Provider::GitHub;

use Moo;

extends 'App::OAuth::Authenticator::Provider';

with 'App::OAuth::Authenticator::OAuth2';

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
