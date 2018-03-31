use utf8;
package App::OAuth::Authenticator::DBIC;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    result_namespace => "Schema",
    resultset_namespace => "ResultSet",
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-29 15:30:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:21lrS/tjjdZUGKBcgpkLnQ

=head1 NAME

App::OAuth::Authenticator::DBIC - State mechanism in DBIx::Class

=head1 METHODS

=head2 token_for %PARAMS

Get or set the OAuth(2) access token for a given principal. Returns
the token (in case of a get) or previous token (in case of a set).

=over 4

=item principal

This is I<our> unique identifier for the principal in question. It
should be either an L<RDF::Trine::Node::Resource> or L<URI> object, or
a string which is expected to be turned directly into one.

=item provider

This is some stable identifier I<we> use to identify the provider,
such as a website root or, ideally, an endpoint URL. If given a L<URI>
or L<RDF::Trine::Node::Resource> object, will handle it appropriately.

It is assumed that provider-specific modules will generate a suitable
value for this field.

=item userid

This is the identifier given to the principal by the provider.
Required when setting a new token. Will likewise process objects as
with L</principal> or L</provider>.

As with the C<provider> field, the provider-specific module is
responsible for putting the right thing in this field.

=item token

This is the OAuth(2) authentication token associated with the
provider, which we store for subsequent use. Obviously required when
setting a new token.

=item expires

This is an optional expiry parameter for the supplied OAuth(2) token,
if known. It can be a L<DateTime> or an epoch number.

=back

=cut

sub token_for {
    my $self = shift;
    my %p = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # if we're passed in a token then we're setting a new token,
    # otherwise we ignore everything but the principal or (provider,
    # userid)

    if ($p{token}) {
        # need principal and provider and userid

        # maybe need expires
    }
    elsif ($p{principal}) {
        # find the bugger using the principal
    }
    elsif ($p{provider} and $p{userid}) {
        # find the bugger using the provider/userid pair
    }
    else {
        # phriggin phail
    }

    my $proc = sub {
        my $p = $self->resultset('Principal')->find_or_create(
        );
        my $rec = $self->resultset('State::Provider')->update_or_create(
        );
    };

    my $rec = $self->txn_do($proc);
}

=head2 state_for %PARAMS

Get or set the session identifier for the given principal. Returns the
session ID (in case of a get) or previous ID (in case of a set).

=over 4

=item principal

The principal we wish to request, either as a string, a L<URI> object,
or an L<RDF::Trine::Node::Resource> object.

=item state

Optionally pass in a specific UUID associated with the principal,
again either as a plain string representation, a L<URI::urn::uuid>
object, or L<RDF::Trine::Node::Resource>.

=item expires

This is an optional expiry parameter for the I<session>, with the same
constraints as with L</token_for>.

=back

=cut

sub state_for {
    my $self = shift;
    my %p = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

}

1;
