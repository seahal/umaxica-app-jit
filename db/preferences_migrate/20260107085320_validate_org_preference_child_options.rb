# frozen_string_literal: true

class ValidateOrgPreferenceChildOptions < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    validate_foreign_key(:org_preference_languages, :org_preference_language_options)
    validate_foreign_key(:org_preference_regions, :org_preference_region_options)
    validate_foreign_key(:org_preference_timezones, :org_preference_timezone_options)
    validate_foreign_key(:org_preference_colorthemes, :org_preference_colortheme_options)
  end
end
