# frozen_string_literal: true

class CreateOrgPreferenceRegionOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_region_options, id: :string do |t|
    end
  end
end
