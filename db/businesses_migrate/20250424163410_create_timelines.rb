class CreateTimelines < ActiveRecord::Migration[8.0]
  def change
    create_table :timelines, id: :uuid do |t|
      t.uuid :parent_id
      t.uuid :succ_id
      t.uuid :prev_id
      t.string :title
      t.string :description
      t.string :entity_status_id
      t.uuid :staff_id
      t.timestamps
    end
  end
end
