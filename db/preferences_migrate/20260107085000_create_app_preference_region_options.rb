# frozen_string_literal: true

class CreateAppPreferenceRegionOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_region_options, id: :uuid do |t|
    end
  end
end
