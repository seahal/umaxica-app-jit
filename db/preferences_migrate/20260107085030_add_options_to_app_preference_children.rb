# frozen_string_literal: true

class AddOptionsToAppPreferenceChildren < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :app_preference_regions, :option_id, :uuid unless column_exists?(:app_preference_regions, :option_id)
    add_index :app_preference_regions, :option_id, name: "index_app_preference_regions_on_option_id", algorithm: :concurrently unless index_exists?(:app_preference_regions, :option_id, name: "index_app_preference_regions_on_option_id")
    add_foreign_key :app_preference_regions, :app_preference_region_options, column: :option_id, primary_key: :id, validate: false unless foreign_key_exists?(:app_preference_regions, :app_preference_region_options, column: :option_id)

    add_column :app_preference_timezones, :option_id, :uuid unless column_exists?(:app_preference_timezones, :option_id)
    add_index :app_preference_timezones, :option_id, name: "index_app_preference_timezones_on_option_id", algorithm: :concurrently unless index_exists?(:app_preference_timezones, :option_id, name: "index_app_preference_timezones_on_option_id")
    add_foreign_key :app_preference_timezones, :app_preference_timezone_options, column: :option_id, primary_key: :id, validate: false unless foreign_key_exists?(:app_preference_timezones, :app_preference_timezone_options, column: :option_id)

    add_column :app_preference_colorthemes, :option_id, :uuid unless column_exists?(:app_preference_colorthemes, :option_id)
    add_index :app_preference_colorthemes, :option_id, name: "index_app_preference_colorthemes_on_option_id", algorithm: :concurrently unless index_exists?(:app_preference_colorthemes, :option_id, name: "index_app_preference_colorthemes_on_option_id")
    add_foreign_key :app_preference_colorthemes, :app_preference_colortheme_options, column: :option_id, primary_key: :id, validate: false unless foreign_key_exists?(:app_preference_colorthemes, :app_preference_colortheme_options, column: :option_id)
  end
end
