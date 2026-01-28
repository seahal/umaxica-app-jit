# frozen_string_literal: true

class AddNotNullToOptionIdInPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!
  TABLES = %i[
    org_preference_timezones
    org_preference_regions
    org_preference_languages
    org_preference_colorthemes

    com_preference_timezones
    com_preference_regions
    com_preference_languages
    com_preference_colorthemes

    app_preference_timezones
    app_preference_regions
    app_preference_languages
    app_preference_colorthemes
  ].freeze

  def up
    TABLES.each do |table_name|
      constraint = "#{table_name}_option_id_null"

      add_check_constraint table_name, "option_id IS NOT NULL",
                           name: constraint, validate: false
      validate_check_constraint table_name, name: constraint
      change_column_null table_name, :option_id, false
      remove_check_constraint table_name, name: constraint
    end
  end

  def down
    TABLES.each do |table_name|
      constraint = "#{table_name}_option_id_null"

      add_check_constraint table_name, "option_id IS NOT NULL",
                           name: constraint, validate: false
      change_column_null table_name, :option_id, true
      remove_check_constraint table_name, name: constraint
    end
  end
end
