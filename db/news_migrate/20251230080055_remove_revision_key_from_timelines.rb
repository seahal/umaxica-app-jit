# frozen_string_literal: true

class RemoveRevisionKeyFromTimelines < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_timelines, :revision_key, :string
      remove_column :com_timelines, :revision_key, :string
      remove_column :org_timelines, :revision_key, :string
    end
  end
end
