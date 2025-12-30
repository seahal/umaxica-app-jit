# frozen_string_literal: true

class AddNeyoToAuditLevels < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Add NEYO level to user_identity_audit_levels
      execute <<~SQL.squish
        INSERT INTO user_identity_audit_levels (id, created_at, updated_at)
        VALUES ('NEYO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (id) DO NOTHING
      SQL

      # Add NEYO level to staff_identity_audit_levels
      execute <<~SQL.squish
        INSERT INTO staff_identity_audit_levels (id, created_at, updated_at)
        VALUES ('NEYO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # No-op to avoid removing reference data used by existing records
  end
end
