# frozen_string_literal: true

class CreateOrganizationStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table :organization_statuses, id: :string, limit: 255 do |t|
      t.string :parent_id, null: false, default: "none", limit: 255

      t.timestamps
    end

    add_index :organization_statuses, :parent_id
  end
end
