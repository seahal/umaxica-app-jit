# frozen_string_literal: true

class CreateOrgPreferenceAuditLevels < ActiveRecord::Migration[8.2]
  def change
    create_table(:org_preference_audit_levels, id: { type: :string, limit: 255, default: "NEYO" }) do |t|
      t.timestamps
    end
  end
end
