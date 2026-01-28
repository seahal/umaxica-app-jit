# frozen_string_literal: true

class RemoveActiveFromTimelineStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :org_timeline_statuses, :active, :boolean
      remove_column :com_timeline_statuses, :active, :boolean
      remove_column :app_timeline_statuses, :active, :boolean
    end
  end
end
