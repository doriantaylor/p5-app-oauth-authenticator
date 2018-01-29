#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::OAuth::Authenticator' ) || print "Bail out!\n";
}

diag( "Testing App::OAuth::Authenticator $App::OAuth::Authenticator::VERSION, Perl $], $^X" );
