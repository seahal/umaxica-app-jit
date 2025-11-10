class CreateComContactStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :com_contact_statuses, id: false do |t|
      t.string :title, primary_key: true, limit: 255
      t.string :description, null: false, limit: 255, default: ""
      t.string :parent_title, limit: 255
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
