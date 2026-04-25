# frozen_string_literal: true

class ValidateAddForeignKeysToStaffAuditTables < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :staff_identity_audits, :staff_identity_audit_events
  end
end
