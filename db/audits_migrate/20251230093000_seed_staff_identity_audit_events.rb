# frozen_string_literal: true

class SeedStaffIdentityAuditEvents < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  STAFF_EVENTS = %w(
    NEYO
    LOGIN_SUCCESS
    LOGIN_FAILURE
    LOGGED_IN
    LOGGED_OUT
    LOGIN_FAILED
    AUTHORIZATION_FAILED
  ).freeze

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def staff_events
    STAFF_EVENTS
  end

  def seed_id(table_name, id)
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
