package App::OAuth::Authenticator::Provider;

use strict;
use warnings FATAL => 'all';

use JSON;
use RDF::Query;

use UUID::URandom      ();
use Data::UUID::NCName ();

use Moo::Role;

# for now, only resolve_principal
requires qw(resolve_principal);

=head2 app

This is a backreference to the application, passed in by the constructor.

=cut

has app => (
    is       => 'rwp',
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

=head2 label

A text label for the provider.

=cut

has label => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $class = ref $_[0];
        my ($label) = ($class =~ /^(?:.*::)?(.+?)$/);

        $label;
    },
);

=head2 state

Unique state token for resolving the provider in the OAuth response.

=cut

has state => (
    is => 'ro',
    default => sub {
        my $uuid = UUID::URandom::create_uuid();
        lc Data::UUID::NCName::to_ncname($uuid, 32);
    },
);

1;
