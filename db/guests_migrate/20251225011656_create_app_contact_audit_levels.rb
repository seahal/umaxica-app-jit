# frozen_string_literal: true

class CreateAppContactAuditLevels < ActiveRecord::Migration[8.2]
  def change
    create_table :app_contact_audit_levels, id: false do |t|
      # rubocop:disable Rails/DangerousColumnNames
      t.primary_key :id, :string, null: false, default: "NONE"
      # rubocop:enable Rails/DangerousColumnNames
      t.timestamps
    end
  end
end
