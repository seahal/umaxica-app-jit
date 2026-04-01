# frozen_string_literal: true

class CreateOrgContactAuditLevels < ActiveRecord::Migration[8.2]
  def change
    create_table(:org_contact_audit_levels, id: false) do |t|
      t.primary_key(:id, :string, null: false, default: "NONE")

      t.timestamps
    end
  end
end
