# frozen_string_literal: true

class AddLevelToStaffIdentityAudits < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      remove_reference(:staff_identity_audits, :level) if column_exists?(:staff_identity_audits, :level_id)
      add_reference(:staff_identity_audits, :level, type: :string, index: true)
      add_foreign_key(:staff_identity_audits, :staff_identity_audit_levels, column: :level_id, primary_key: :id)
    end
  end

  def down
    safety_assured do
      remove_foreign_key(:staff_identity_audits, :staff_identity_audit_levels, column: :level_id)
      remove_reference(:staff_identity_audits, :level)
    end
  end
end
