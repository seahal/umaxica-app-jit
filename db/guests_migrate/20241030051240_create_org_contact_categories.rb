class CreateOrgContactCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :org_contact_categories, id: false do |t|
      t.string :title, primary_key: true, limit: 255
      t.string :description, null: false, limit: 255, default: ""
      # hierarchical bits for CTE
      t.string :parent_title, limit: 255, null: true
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
