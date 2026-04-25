# frozen_string_literal: true

class AddLevelToUserIdentityAudits < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      remove_reference(:user_identity_audits, :level) if column_exists?(:user_identity_audits, :level_id)
      add_reference(:user_identity_audits, :level, type: :string, index: true)
      add_foreign_key(:user_identity_audits, :user_identity_audit_levels, column: :level_id, primary_key: :id)
    end
  end

  def down
    safety_assured do
      remove_foreign_key(:user_identity_audits, :user_identity_audit_levels, column: :level_id)
      remove_reference(:user_identity_audits, :level)
    end
  end
end
