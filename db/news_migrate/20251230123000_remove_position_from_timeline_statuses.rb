# frozen_string_literal: true

class RemovePositionFromTimelineStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i(app_timeline_statuses com_timeline_statuses org_timeline_statuses).each do |table|
        remove_column table, :position, :integer if column_exists?(table, :position)
      end
    end
  end
end
