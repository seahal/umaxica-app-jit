# frozen_string_literal: true

class CreateAppPreferenceRegions < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_regions, id: :uuid do |t|
      t.references :preference, null: false, foreign_key: { to_table: :app_preferences }, type: :uuid

      t.timestamps
    end
  end
end
