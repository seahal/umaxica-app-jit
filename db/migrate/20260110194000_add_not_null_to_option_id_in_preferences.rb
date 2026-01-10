# frozen_string_literal: true

class AddNotNullToOptionIdInPreferences < ActiveRecord::Migration[8.2]
  def change
    change_column_null :org_preference_timezones, :option_id, false, "Asia/Tokyo"
    change_column_null :org_preference_regions, :option_id, false, "JP"
    change_column_null :org_preference_languages, :option_id, false, "JA"
    change_column_null :org_preference_colorthemes, :option_id, false, "system"

    change_column_null :com_preference_timezones, :option_id, false, "Asia/Tokyo"
    change_column_null :com_preference_regions, :option_id, false, "JP"
    change_column_null :com_preference_languages, :option_id, false, "JA"
    change_column_null :com_preference_colorthemes, :option_id, false, "system"

    change_column_null :app_preference_timezones, :option_id, false, "Asia/Tokyo"
    change_column_null :app_preference_regions, :option_id, false, "JP"
    change_column_null :app_preference_languages, :option_id, false, "JA"
    change_column_null :app_preference_colorthemes, :option_id, false, "system"
  end
end
