# frozen_string_literal: true

class AddStatusIdToComTimelines < ActiveRecord::Migration[8.2]
  def change
    add_column :com_timelines, :status_id, :string, limit: 255, null: false, default: "NONE"
    add_index :com_timelines, :status_id
  end
end
