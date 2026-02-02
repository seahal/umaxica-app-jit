# frozen_string_literal: true

class AddLowerCodeUniqueIndexesPreference < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %w(
    app_preference_colortheme_options
    app_preference_language_options
    app_preference_region_options
    app_preference_statuses
    app_preference_timezone_options
    com_preference_colortheme_options
    com_preference_language_options
    com_preference_region_options
    com_preference_statuses
    com_preference_timezone_options
    org_preference_colortheme_options
    org_preference_language_options
    org_preference_region_options
    org_preference_statuses
    org_preference_timezone_options
  ).freeze

  def up
    safety_assured do
      TABLES.each do |table|
        add_lower_code_index(table)
      end
    end
  end

  def down
    TABLES.each do |table|
      index_name = "index_#{table}_on_lower_code"
      remove_index table, name: index_name if index_exists?(table, nil, name: index_name)
    end
  end

  private

  def add_lower_code_index(table)
    return unless table_exists?(table) && column_exists?(table, :code)

    index_name = "index_#{table}_on_lower_code"
    return if index_exists?(table, nil, name: index_name)

    add_index table, "lower(code)", unique: true, name: index_name, algorithm: :concurrently
  end
end
