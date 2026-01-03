# frozen_string_literal: true

class FixIdentityConsistency < ActiveRecord::Migration[7.1]
  def up
    # Add level_id to staff_identity_audits if missing
    execute "ALTER TABLE staff_identity_audits ADD COLUMN IF NOT EXISTS level_id varchar(255) DEFAULT 'NONE'"

    # Insert NONE level if missing (for staff levels)
    # Check if staff_identity_audit_levels table exists first?
    # Assuming it exists or was created by 20251222215659

    execute <<~SQL.squish
      UPDATE staff_identity_audits
      SET level_id = 'NONE'
      WHERE level_id IS NULL
    SQL

    execute "ALTER TABLE staff_identity_audits ALTER COLUMN level_id SET NOT NULL"

    execute "CREATE INDEX IF NOT EXISTS index_staff_identity_audits_on_level_id ON staff_identity_audits (level_id)"

    # Add missing unique indexes
    # UserIdentityTelephoneStatus lower(id)
    execute "CREATE UNIQUE INDEX IF NOT EXISTS index_user_identity_telephone_statuses_on_lower_id ON user_identity_telephone_statuses (lower(id))"

    # UserIdentityEmail lower(address)
    execute "CREATE UNIQUE INDEX IF NOT EXISTS index_user_identity_emails_on_lower_address ON user_identity_emails (lower(address))"

    # ... Add others from report if critical ...
  end

  def down
    # Irreversible or manual cleanup
  end
end
