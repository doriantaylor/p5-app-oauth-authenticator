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

=head2 prepare_login_uri

=cut

sub prepare_login_uri {
    my $self = shift;
    my %p = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    $p{state} ||= $self->state,
    $p{scope} ||= ref $self->scope eq 'ARRAY' ?
        join(' ', @{$self->scope}) : $self->scope;
    $p{redirect_uri} ||= delete $p{redirect} if $p{redirect};

    if (ref $p{redirect_uri} and Scalar::Util::blessed($p{redirect_uri})
            and $p{redirect_uri}->isa('URI')) {
        $p{redirect_uri} = $p{redirect_uri}->as_string;
    }

    $self->_wrap_auth_uri(%p);
}

1;
