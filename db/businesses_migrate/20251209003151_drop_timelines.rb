class DropTimelines < ActiveRecord::Migration[8.2]
  def up
    drop_table :timelines if table_exists?(:timelines)
  end

  def down
    create_table :timelines, id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
