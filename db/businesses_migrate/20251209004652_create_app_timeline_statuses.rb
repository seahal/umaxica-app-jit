class CreateAppTimelineStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :app_timeline_statuses, id: :string, limit: 255 do |t|
      t.timestamps
    end

    execute "ALTER TABLE app_timeline_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :app_timeline_statuses
  end
end
