# frozen_string_literal: true

class AddUniqueConstraintsToPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # App Preferences
    replace_index(:app_preference_regions, :preference_id)
    replace_index(:app_preference_timezones, :preference_id)
    replace_index(:app_preference_languages, :preference_id)
    replace_index(:app_preference_colorthemes, :preference_id)
    replace_index(:app_preference_cookies, :preference_id)

    # Com Preferences
    replace_index(:com_preference_regions, :preference_id)
    replace_index(:com_preference_timezones, :preference_id)
    replace_index(:com_preference_languages, :preference_id)
    replace_index(:com_preference_colorthemes, :preference_id)
    replace_index(:com_preference_cookies, :preference_id)

    # Org Preferences
    replace_index(:org_preference_regions, :preference_id)
    replace_index(:org_preference_timezones, :preference_id)
    replace_index(:org_preference_languages, :preference_id)
    replace_index(:org_preference_colorthemes, :preference_id)
    replace_index(:org_preference_cookies, :preference_id)
  end

  private

  def replace_index(table, column)
    old_index_name = "index_#{table}_on_#{column}"
    remove_index(table, column, name: old_index_name, algorithm: :concurrently) if index_exists?(
      table, column,
      name: old_index_name,
    )
    add_index(table, column, name: old_index_name, unique: true, algorithm: :concurrently)
  end
end
