# frozen_string_literal: true

class RemovePermalinkFromTimelines < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_timelines, :permalink, :string
      remove_column :com_timelines, :permalink, :string
      remove_column :org_timelines, :permalink, :string
    end
  end
end
