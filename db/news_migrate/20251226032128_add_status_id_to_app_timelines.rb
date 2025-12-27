# frozen_string_literal: true

class AddStatusIdToAppTimelines < ActiveRecord::Migration[8.2]
  def change
    add_column :app_timelines, :status_id, :string, limit: 255, null: false, default: "NONE"
    add_index :app_timelines, :status_id
  end
end
