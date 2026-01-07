# frozen_string_literal: true

class CreateComPreferenceRegionOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preference_region_options, id: :string do |t|
    end
  end
end
