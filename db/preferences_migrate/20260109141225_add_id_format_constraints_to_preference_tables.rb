# frozen_string_literal: true

class AddIdFormatConstraintsToPreferenceTables < ActiveRecord::Migration[8.2]
  # Preference tables with string IDs that should only allow uppercase alphanumeric + underscore

  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    [
      # Only Status tables should have uppercase alphanumeric constraints
      # Option tables contain timezone IDs, language codes, etc. which may have different formats
      "org_preference_statuses",
      "com_preference_statuses",
      "app_preference_statuses",
    ]
  end
end
