# frozen_string_literal: true

class AddForeignKeysToContactAudits < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :app_contact_histories, :app_contact_audit_levels, column: :level_id, primary_key: :id
    add_foreign_key :com_contact_audits, :com_contact_audit_levels, column: :level_id, primary_key: :id
    add_foreign_key :org_contact_histories, :org_contact_audit_levels, column: :level_id, primary_key: :id
  end
end
