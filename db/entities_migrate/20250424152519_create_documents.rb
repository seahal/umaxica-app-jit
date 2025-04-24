class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.binary :parent_id
      t.binary :prev_id
      t.binary :succ_id
      t.string :title
      t.string :description
      t.string :entity_status_id
      t.timestamps
    end
  end
end
