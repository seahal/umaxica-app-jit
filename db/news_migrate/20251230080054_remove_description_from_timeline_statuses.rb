# frozen_string_literal: true

class RemoveDescriptionFromTimelineStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_timeline_statuses, :description, :string
      remove_column :com_timeline_statuses, :description, :string
      remove_column :org_timeline_statuses, :description, :string
    end
  end
end
