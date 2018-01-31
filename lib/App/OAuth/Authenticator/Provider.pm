package App::OAuth::Authenticator::Provider;

use Moo;

has id => (
    is       => 'ro',
    required => 1,
);

has secret => (
    is       => 'ro',
    required => 1,
);

has app => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

1;
