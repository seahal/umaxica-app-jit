# frozen_string_literal: true

class FixPreferenceReplacementForeignKeys < ActiveRecord::Migration[8.2]
  TABLES = %i(app_preferences com_preferences org_preferences).freeze

  def up
    safety_assured do
      TABLES.each do |table|
        next unless table_exists?(table)
        next unless column_exists?(table, :replaced_by_id)

        remove_foreign_key(table, column: :replaced_by_id) if foreign_key_exists?(table, column: :replaced_by_id)
        add_foreign_key(table, table, column: :replaced_by_id, on_delete: :nullify, validate: false)
      end
    end
  end

  def down
    safety_assured do
      TABLES.each do |table|
        next unless table_exists?(table)
        next unless column_exists?(table, :replaced_by_id)

        remove_foreign_key(table, column: :replaced_by_id) if foreign_key_exists?(table, column: :replaced_by_id)
        add_foreign_key(table, table, column: :replaced_by_id, validate: false)
      end
    end
  end
end
