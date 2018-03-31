package App::OAuth::Authenticator::Generic;

use strict;
use warnings FATAL => 'all';

=head1 NAME

App::OAuth::Authenticator::Generic - Role common to OAuth 1 and 2

=cut

use Moo::Role;

requires qw(auth_uri token_uri scope ua);

=head1 ACCESSORS

=head2 id

The OAuth C<client_id>.

=cut

has id => (
    is       => 'ro',
    required => 1,
);

=head2 secret

The OAuth C<client_secret>.

=cut

has secret => (
    is       => 'ro',
    required => 1,
);

1;
