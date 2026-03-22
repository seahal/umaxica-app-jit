# frozen_string_literal: true

class ValidateAppPreferenceChildOptions < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    validate_foreign_key(:app_preference_languages, :app_preference_language_options)
    validate_foreign_key(:app_preference_regions, :app_preference_region_options)
    validate_foreign_key(:app_preference_timezones, :app_preference_timezone_options)
    validate_foreign_key(:app_preference_colorthemes, :app_preference_colortheme_options)
  end
end
