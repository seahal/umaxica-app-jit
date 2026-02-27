# frozen_string_literal: true

# Migration to add foreign keys for preference status associations
# This resolves ForeignKeyChecker warnings for preference status associations
class AddPreferenceStatusForeignKeys < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_fk_if_integer(:app_preferences, :app_preference_statuses)
    add_fk_if_integer(:com_preferences, :com_preference_statuses)
    add_fk_if_integer(:org_preferences, :org_preference_statuses)
  end

  private

  def add_fk_if_integer(table, ref_table)
    return unless column_exists?(table, :status_id)

    column = connection.columns(table).find { |col| col.name == "status_id" }
    return unless column
    return unless [:integer, :bigint].include?(column.type)

    add_foreign_key table, ref_table,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false
  end
end
