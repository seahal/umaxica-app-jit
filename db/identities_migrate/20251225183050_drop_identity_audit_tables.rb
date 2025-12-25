# frozen_string_literal: true

class DropIdentityAuditTables < ActiveRecord::Migration[8.2]
  def up
    # Drop User Identity Audit tables
    drop_table :user_identity_audits if table_exists?(:user_identity_audits)
    drop_table :user_identity_audit_events if table_exists?(:user_identity_audit_events)
    drop_table :user_identity_audit_levels if table_exists?(:user_identity_audit_levels)

    # Drop Staff Identity Audit tables
    drop_table :staff_identity_audits if table_exists?(:staff_identity_audits)
    drop_table :staff_identity_audit_events if table_exists?(:staff_identity_audit_events)
    drop_table :staff_identity_audit_levels if table_exists?(:staff_identity_audit_levels)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore dropped audit tables"
  end
end
