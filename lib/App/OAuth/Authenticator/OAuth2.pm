package App::OAuth::Authenticator::OAuth2;

=head1 NAME

App::OAuth::Authenticator::OAuth2 - Role encapsulating OAuth 2.0

=cut

use Net::OAuth2::Profile::WebServer;

use Moo::Role;

with 'App::OAuth::Authenticator::Generic';


1;
