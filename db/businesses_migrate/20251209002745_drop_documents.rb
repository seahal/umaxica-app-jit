class DropDocuments < ActiveRecord::Migration[8.2]
  def up
    drop_table :documents if table_exists?(:documents)
  end

  def down
    create_table :documents, id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
