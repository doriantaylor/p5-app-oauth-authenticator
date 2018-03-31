use utf8;
package App::OAuth::Authenticator::DBIC::Schema::State::Provider;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::OAuth::Authenticator::DBIC::Schema::State::Provider

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

=head1 TABLE: C<provider_state>

=cut

__PACKAGE__->table("provider_state");

=head1 ACCESSORS

=head2 principal

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 provider

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 userid

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 expires

  data_type: 'timestamp'
  default_value: infinity
  is_nullable: 0

=head2 token

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "principal",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "provider",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "userid",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "expires",
  { data_type => "timestamp", default_value => "infinity", is_nullable => 0 },
  "token",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</principal>

=item * L</provider>

=back

=cut

__PACKAGE__->set_primary_key("principal", "provider");

=head1 UNIQUE CONSTRAINTS

=head2 C<uq_provider_state>

=over 4

=item * L</provider>

=item * L</userid>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_provider_state", ["provider", "userid"]);

=head1 RELATIONS

=head2 principal

Type: belongs_to

Related object: L<App::OAuth::Authenticator::DBIC::Schema::Principal>

=cut

__PACKAGE__->belongs_to(
  "principal",
  "App::OAuth::Authenticator::DBIC::Schema::Principal",
  { id => "principal" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-03-31 12:03:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cQixDL7CM3AWrjZzujVXFQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
