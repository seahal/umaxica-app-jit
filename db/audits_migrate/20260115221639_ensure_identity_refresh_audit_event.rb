# frozen_string_literal: true

class EnsureIdentityRefreshAuditEvent < ActiveRecord::Migration[8.2]
  EVENT_ID = "TOKEN_REFRESHED"

  def up
    seed_event("user_audit_events")
    seed_event("staff_audit_events")
  end

  def down
    # No-op: leave reference data in place.
  end

  private

  def seed_event(table_name)
    return unless table_exists?(table_name)

    if column_exists?(table_name, :created_at)
      safety_assured do
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id, created_at, updated_at)
          VALUES ('#{EVENT_ID}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    else
      safety_assured do
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id)
          VALUES ('#{EVENT_ID}')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end
end
