class CreateOrgContactStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :org_contact_statuses, id: :string, limit: 255 do |t|
      t.string :description, null: false, limit: 255, default: ""
      t.string :parent_title, limit: 255
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
