# frozen_string_literal: true

class ChangeSlugIdLimitInTimelines < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          change_column(:app_timelines, :slug_id, :string, limit: 32)
          change_column(:com_timelines, :slug_id, :string, limit: 32)
          change_column(:org_timelines, :slug_id, :string, limit: 32)
        end

        dir.down do
          change_column(:app_timelines, :slug_id, :string, limit: 255)
          change_column(:com_timelines, :slug_id, :string, limit: 255)
          change_column(:org_timelines, :slug_id, :string, limit: 255)
        end
      end
    end
  end
end
