class CreateDocuments < ActiveRecord::Migration[8.2]
  def change
    create_table :documents, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.binary :parent_id
      t.binary :prev_id
      t.binary :succ_id
      t.string :title
      t.string :description
      t.string :entity_status_id
      t.binary :staff_id
      t.timestamps
    end
  end
end
