# frozen_string_literal: true

class BackfillOptionIdInPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES_WITH_DEFAULTS = {
    org_preference_timezones: "Asia/Tokyo",
    org_preference_regions: "JP",
    org_preference_languages: "JA",
    org_preference_colorthemes: "system",

    com_preference_timezones: "Asia/Tokyo",
    com_preference_regions: "JP",
    com_preference_languages: "JA",
    com_preference_colorthemes: "system",

    app_preference_timezones: "Asia/Tokyo",
    app_preference_regions: "JP",
    app_preference_languages: "JA",
    app_preference_colorthemes: "system"
  }.freeze

  def up
    safety_assured do
      TABLES_WITH_DEFAULTS.each do |table_name, default|
        execute("UPDATE #{table_name} SET option_id = '#{default}' WHERE option_id IS NULL")
      end
    end
  end
end
