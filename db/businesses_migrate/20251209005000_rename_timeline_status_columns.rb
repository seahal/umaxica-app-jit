class RenameTimelineStatusColumns < ActiveRecord::Migration[8.2]
  def up
    rename_column :app_timelines, :entity_status_id, :app_timeline_status_id if column_exists?(:app_timelines, :entity_status_id)
    rename_column :org_timelines, :entity_status_id, :org_timeline_status_id if column_exists?(:org_timelines, :entity_status_id)
    rename_column :com_timelines, :entity_status_id, :com_timeline_status_id if column_exists?(:com_timelines, :entity_status_id)
  end

  def down
    rename_column :app_timelines, :app_timeline_status_id, :entity_status_id if column_exists?(:app_timelines, :app_timeline_status_id)
    rename_column :org_timelines, :org_timeline_status_id, :entity_status_id if column_exists?(:org_timelines, :org_timeline_status_id)
    rename_column :com_timelines, :com_timeline_status_id, :entity_status_id if column_exists?(:com_timelines, :com_timeline_status_id)
  end
end
