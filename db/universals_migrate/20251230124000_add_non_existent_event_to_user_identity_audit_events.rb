# frozen_string_literal: true

class AddNonExistentEventToUserIdentityAuditEvents < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:user_identity_audit_events)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO user_identity_audit_events (id, created_at, updated_at)
        VALUES ('NON_EXISTENT_EVENT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # No-op to avoid removing reference data used by existing records
  end
end
