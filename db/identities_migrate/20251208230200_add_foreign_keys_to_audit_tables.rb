class AddForeignKeysToAuditTables < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :user_identity_audits, :user_identity_audit_events, column: :event_id
    add_foreign_key :staff_identity_audits, :staff_identity_audit_events, column: :event_id
  end
end
