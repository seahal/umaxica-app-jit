# frozen_string_literal: true

class RemoveParentIdFromOrganizationStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_index :organization_statuses, :parent_id, if_exists: true
      remove_column :organization_statuses, :parent_id, :string, limit: 255, default: "none", null: false
    end
  end
end
