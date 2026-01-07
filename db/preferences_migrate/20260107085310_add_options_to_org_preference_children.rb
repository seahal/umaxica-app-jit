# frozen_string_literal: true

class AddOptionsToOrgPreferenceChildren < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :org_preference_languages, :option_id, :string
    add_index :org_preference_languages, :option_id, name: "index_org_preference_languages_on_option_id", algorithm: :concurrently
    add_foreign_key :org_preference_languages, :org_preference_language_options, column: :option_id, primary_key: :id, validate: false

    add_column :org_preference_regions, :option_id, :string
    add_index :org_preference_regions, :option_id, name: "index_org_preference_regions_on_option_id", algorithm: :concurrently
    add_foreign_key :org_preference_regions, :org_preference_region_options, column: :option_id, primary_key: :id, validate: false

    add_column :org_preference_timezones, :option_id, :string
    add_index :org_preference_timezones, :option_id, name: "index_org_preference_timezones_on_option_id", algorithm: :concurrently
    add_foreign_key :org_preference_timezones, :org_preference_timezone_options, column: :option_id, primary_key: :id, validate: false

    add_column :org_preference_colorthemes, :option_id, :string
    add_index :org_preference_colorthemes, :option_id, name: "index_org_preference_colorthemes_on_option_id", algorithm: :concurrently
    add_foreign_key :org_preference_colorthemes, :org_preference_colortheme_options, column: :option_id, primary_key: :id, validate: false
  end
end
