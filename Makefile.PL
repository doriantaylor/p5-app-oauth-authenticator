use 5.012;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name        'App-OAuth-Authenticator';
readme_from 'lib/App/OAuth/Authenticator.pm';
all_from    'lib/App/OAuth/Authenticator.pm';
author      q{Dorian Taylor <dorian@cpan.org>};
license     'apache';

perl_version 5.012;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#App-OAuth-Authenticator',
   license    => 'http://www.apache.org/licenses/LICENSE-2.0',
   repository => 'git://github.com/doriantaylor/p5-app-oauth-authenticator.git',
   bugtracker => 'https://github.com/doriantaylor/p5-app-oauth-authenticator/issues',
);

configure_requires (
    'Module::Install' => 0,
);

build_requires (
    'Test::More' => 0,
);

requires (
    'Moo'                   => '2.003',
    'URI'                   => '1.69',
    'URI::QueryParam'       => '1.69',
    'JSON'                  => '2.90',
    'MIME::Base64'          => '3.14',
    'UUID::Tiny'            => '1.04',
    'Role::Markup::XML'     => '0.07',
    'DBIx::Class'           => '0.082821',
    'RDF::Trine'            => '1.018',
    'Net::OAuth'            => '0.28',
    'Net::OAuth2'           => '0.63',
    'Plack::Request'        => '1.0037',
    'Config::Any'           => '0.26',
    'String::RewritePrefix' => '0.007',
    'Class::Load'           => '0.23',
);

install_as_cpan;
auto_install;
WriteAll;
