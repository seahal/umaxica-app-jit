class CreateOrgTimelines < ActiveRecord::Migration[8.2]
  def change
    create_table :org_timelines, id: :uuid do |t|
      t.uuid :parent_id
      t.uuid :prev_id
      t.uuid :succ_id
      t.string :title
      t.string :description
      t.string :org_timeline_status_id, limit: 255
      t.uuid :staff_id
      t.timestamps
    end
  end
end
