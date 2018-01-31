package App::OAuth::Authenticator;

use 5.012;
use strict;
use warnings FATAL => 'all';

=head1 NAME

App::OAuth::Authenticator - A (standalone) OAuth(2) authenticator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  # on the shell

  $ plackup `which app-oauth-authenticator.psgi`

=head1 METHODS

=head2 function1

=cut

# We start and end with the authenticator:

# Simple conditional: if there's a cookie present with the specified
# key, look it up in the database. If there's a principal associated
# with the cookie (and it hasn't expired), set the special header to
# that (to be picked up by the apache module) and return 200.

# Otherwise, we can do one of two things: We can return 401 with the
# NASCAR page content, or we can redirect to it, taking care to
# provide it information about where to redirect back to.

# Note that the authenticator is not a conventional resource with a
# location like the other resources. It is run through a side channel
# and hooked via the FCGI_ROLE environment variable.

# Next: A NASCAR-esque list of all the providers:

# This is really the only UI: a bunch of links to the different
# providers. Each link must contain enough information to resolve not
# only the provider (when the provider redirects the UA back to the
# confirmation target), but also the original resource the UA was
# coming from. (The latter should be checked for cleanliness.)

# Finally: The confirmation/validation target:

# This is the resource that the UA gets redirected back to with the
# nonce (or 'code' in OAuth 2), which behind the scenes gets traded
# with the provider for an access token. This should be a
# meta-resource with two parameters, in addition to the OAuth ones:
# something to positively identify the provider (e.g. a slug,
# otherwise we won't know which provider the nonce belongs to), and
# the original requested URI to finally redirect to upon successful
# validation of the principal. The latter ought to have been along for
# the ride ever since being set by the authenticator.

# (Note that since this original URI can contain a query string, we
# should probably Base64-encode it. Likewise, we shouldn't trust the
# OAuth providers to faithfully relay any extraneous query parameters,
# and thus just encode our parameters into the path of the target URI.)

# Example: /oauth/confirm/$PROVIDER/$REDIRECT_BASE64?oauth=params

# Resolution/validation of the principal can proceed once we have the
# access token from the provider. This process will be distinct and
# proprietary to each provider, and thus handled by provider-specific
# plugins. The common thread is that we query the provider's API for
# some positively-identifying information that we can match to our
# existing whitelist. (Alternatively we can skip the whitelist and
# just 'sign up' whoever comes along. This alternative may entail an
# additional piece of UI, so for now let's just leave it out of scope.)

# Validation against the whitelist is done (for now) against an RDF
# graph. We identify (through configuration) one or more resources in
# the graph to be "origins". A valid principal either *is* an origin,
# or it is somehow topologically connected to one.

# Since the information we get from the provider's API may not match
# directly to a property of a principal, and since either the provider
# or ourselves may not have every conceivable matching pair of
# identifiers, we may need to make multiple comparisons, and
# ultimately multiple *calls* to the provider's API. This matching
# process should nevertheless be encapsulated into a single method. If
# successful, the graph may be augmented (i.e., any applicable blanks
# filled in) with the information found in the API responses. If this
# method fails to produce a principal, the UA should be shown the
# NASCAR page (either in situ or via redirect) to select a different
# provider. (We can include a parameter to discount the providers
# which have been exhausted.)

# An option to consider is to use the provider to gather intel on
# other members of the whitelist to fill in data gaps and facilitate
# matching. For example, both GitHub and Slack have 'organizations'
# and 'teams', respectively, which can be used to triangulate other
# members of the whitelist and give the system an easier time
# identifying them. However, in almost all cases this would require
# more API privileges than are needed to simply identify the
# principal, so we would need some explicit UI and content to
# carefully explain what the hell is going on.



sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Dorian Taylor, C<< <dorian at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/doriantaylor/p5-app-oauth-authenticator/issues> .

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc App::OAuth::Authenticator

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-OAuth-Authenticator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-OAuth-Authenticator>

=item * Search CPAN

L<http://search.cpan.org/dist/App-OAuth-Authenticator/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Dorian Taylor.

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at
L<http://www.apache.org/licenses/LICENSE-2.0>.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.

=cut

1; # End of App::OAuth::Authenticator
