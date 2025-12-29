# frozen_string_literal: true

class AddNeyoToAppTimelineStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO app_timeline_statuses (id, description, active, position, created_at, updated_at)
        VALUES ('NEYO', 'Default Status', true, 0, NOW(), NOW())
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    execute "DELETE FROM app_timeline_statuses WHERE id = 'NEYO';"
  end
end
