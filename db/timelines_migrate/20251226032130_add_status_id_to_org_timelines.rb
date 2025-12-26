class AddStatusIdToOrgTimelines < ActiveRecord::Migration[8.2]
  def change
    add_column :org_timelines, :status_id, :string, limit: 255, null: false, default: "NONE"
    add_index :org_timelines, :status_id
  end
end
