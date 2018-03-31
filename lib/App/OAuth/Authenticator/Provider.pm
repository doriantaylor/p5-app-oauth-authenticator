package App::OAuth::Authenticator::Provider;

use strict;
use warnings FATAL => 'all';

use JSON;

use Moo::Role;

# for now, only resolve_principal
requires qw(resolve_principal);

=head2 app

This is a backreference to the application, passed in by the constructor.

=cut

has app => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

=head2 json

A handy JSON parser/serializer.

=cut

has json => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { JSON->new },
);

1;
