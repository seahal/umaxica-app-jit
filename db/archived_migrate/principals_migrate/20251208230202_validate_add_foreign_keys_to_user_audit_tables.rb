# frozen_string_literal: true

class ValidateAddForeignKeysToUserAuditTables < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :user_identity_audits, :user_identity_audit_events
  end
end
