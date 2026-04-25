# frozen_string_literal: true

class ValidateCreateContactAuditEvents < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:com_contact_histories, :com_contact_audit_events)
    validate_foreign_key(:app_contact_histories, :app_contact_audit_events)
    validate_foreign_key(:org_contact_histories, :org_contact_audit_events)
  end
end
