# frozen_string_literal: true

class AddNeyoToIdentityAuditRefs < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  ID_TABLES = %w(
    user_identity_audit_events
    user_identity_audit_levels
    staff_identity_audit_events
    staff_identity_audit_levels
  ).freeze

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def seed_id(table_name, id)
    return unless table_exists?(table_name)

    cols = ["id"]
    vals = [connection.quote(id)]

    if column_exists?(table_name, :created_at)
      cols << "created_at"
      vals << "CURRENT_TIMESTAMP"
    end

    if column_exists?(table_name, :updated_at)
      cols << "updated_at"
      vals << "CURRENT_TIMESTAMP"
    end

    execute <<~SQL.squish
      INSERT INTO #{table_name} (#{cols.join(", ")})
      VALUES (#{vals.join(", ")})
      ON CONFLICT (id) DO NOTHING
    SQL
  end
end
