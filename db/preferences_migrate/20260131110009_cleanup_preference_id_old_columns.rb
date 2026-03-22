# frozen_string_literal: true

class CleanupPreferenceIdOldColumns < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      option_tables = %w(
        app_preference_colortheme_options app_preference_language_options
        app_preference_region_options app_preference_timezone_options
        com_preference_colortheme_options com_preference_language_options
        com_preference_region_options com_preference_timezone_options
        org_preference_colortheme_options org_preference_language_options
        org_preference_region_options org_preference_timezone_options
      )
      status_tables = %w(
        app_preference_statuses com_preference_statuses org_preference_statuses
      )

      (option_tables + status_tables).each do |table|
        remove_column(table, :id_old)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
