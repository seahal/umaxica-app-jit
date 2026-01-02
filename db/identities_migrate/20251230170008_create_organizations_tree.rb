# frozen_string_literal: true

class CreateOrganizationsTree < ActiveRecord::Migration[8.2]
  def change
    create_table :organizations, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :parent, foreign_key: { to_table: :organizations, validate: false }, type: :uuid
      t.string :organization_status_id, null: false, limit: 255

      t.timestamps
    end

    add_index :organizations, :organization_status_id
    add_index :organizations, [:parent_id, :organization_status_id],
              unique: true, name: "index_organizations_unique"

    add_foreign_key :organizations, :organization_statuses,
                    column: :organization_status_id, primary_key: :id, validate: false
  end
end
