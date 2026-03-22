# frozen_string_literal: true

class RenamePublicIdToSlugIdInTimelines < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      rename_column(:app_timelines, :public_id, :slug_id)
      rename_column(:com_timelines, :public_id, :slug_id)
      rename_column(:org_timelines, :public_id, :slug_id)
    end
  end
end
