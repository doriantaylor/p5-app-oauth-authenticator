use utf8;
package App::OAuth::Authenticator::DBIC::Schema::State::Principal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::OAuth::Authenticator::DBIC::Schema::State::Principal

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

=head1 TABLE: C<principal_state>

=cut

__PACKAGE__->table("principal_state");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 principal

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 expires

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "principal",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "expires",
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

=head1 UNIQUE CONSTRAINTS

=head2 C<uq_principal_state>

=over 4

=item * L</principal>

=back

=cut

__PACKAGE__->add_unique_constraint("uq_principal_state", ["principal"]);

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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2018-01-29 15:30:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m/JYENYToMcpDR9N4EKHIA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
