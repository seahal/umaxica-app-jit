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
    return unless table_exists?(:staff_identity_audit_events)

    safety_assured do
      staff_events.each do |id|
        seed_id(:staff_identity_audit_events, id)
      end
    end
  end

  def down
    # No-op to avoid removing shared reference data.
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
