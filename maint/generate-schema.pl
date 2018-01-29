#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use DBIx::Class::Schema::Loader ();

DBIx::Class::Schema::Loader::make_schema_at(
    'App::OAuth::Authenticator::DBIC',
    {
        dump_directory          => './lib',
        overwrite_modifications => 1,
        really_erase_my_files   => 0,
        components              => [qw(PK::Auto InflateColumn::DateTime)],
        relationships           => 1,
        naming                  => 'current',
        use_namespaces          => 1,
        result_namespace        => 'Schema',
        resultset_namespace     => 'ResultSet',
        rel_name_map => {
            principal_state => 'state',
            provider_states => 'providers',
        },
        moniker_map => {
            provider_state  => 'State::Provider',
            principal_state => 'State::Principal',
        },
    },
    \@ARGV,
);
