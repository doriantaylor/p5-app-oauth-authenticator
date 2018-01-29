use utf8;
package App::OAuth::Authenticator::DBIC::Schema::Principal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::OAuth::Authenticator::DBIC::Schema::Principal

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::PK::Auto>

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime");

=head1 TABLE: C<principal>

=cut

__PACKAGE__->table("principal");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 identified

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "identified",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 providers

Type: has_many

Related object: L<App::OAuth::Authenticator::DBIC::Schema::State::Provider>

=cut

__PACKAGE__->has_many(
  "providers",
  "App::OAuth::Authenticator::DBIC::Schema::State::Provider",
  { "foreign.principal" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 state

Type: might_have

Related object: L<App::OAuth::Authenticator::DBIC::Schema::State::Principal>

=cut

__PACKAGE__->might_have(
  "state",
  "App::OAuth::Authenticator::DBIC::Schema::State::Principal",
  { "foreign.principal" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-29 15:33:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yD/oMmXsrQDArx3Y3YWopw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
