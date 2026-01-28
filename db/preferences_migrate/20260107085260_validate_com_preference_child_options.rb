# frozen_string_literal: true

class ValidateComPreferenceChildOptions < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    validate_foreign_key :com_preference_languages, :com_preference_language_options
    validate_foreign_key :com_preference_regions, :com_preference_region_options
    validate_foreign_key :com_preference_timezones, :com_preference_timezone_options
    validate_foreign_key :com_preference_colorthemes, :com_preference_colortheme_options
  end
end
