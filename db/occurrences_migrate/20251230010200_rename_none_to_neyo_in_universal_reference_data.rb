# frozen_string_literal: true

class RenameNoneToNeyoInUniversalReferenceData < ActiveRecord::Migration[8.2]
  def up
    rename_id_tables(
      %w(
        user_occurrence_statuses
        staff_occurrence_statuses
      ), from: "NONE", to: "NEYO",
    )

    update_fk(:user_occurrences, :status_id, from: "NONE", to: "NEYO")
    update_fk(:staff_occurrences, :status_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:user_occurrences, :status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_occurrences, :status_id, from: "NONE", to: "NEYO")
  end

  def down
    rename_id_tables(
      %w(
        user_occurrence_statuses
        staff_occurrence_statuses
      ), from: "NEYO", to: "NONE",
    )

    update_fk(:user_occurrences, :status_id, from: "NEYO", to: "NONE")
    update_fk(:staff_occurrences, :status_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:user_occurrences, :status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_occurrences, :status_id, from: "NEYO", to: "NONE")
  end

  private

  def rename_id_tables(tables, from:, to:)
    tables.each do |table|
      rename_id(table, from: from, to: to)
    end
  end

  def rename_id(table, from:, to:)
    return unless table_exists?(table)

    change_column_default_if_exists(table, :id, from: from, to: to)
  end

  def update_fk(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET #{column} = '#{to}'
        WHERE #{column} = '#{from}'
      SQL
    end
  end

  def update_audit_fks(tables, from:, to:)
    tables.each do |table|
      update_fk(table, :event_id, from: from, to: to)
      update_fk(table, :level_id, from: from, to: to)
    end
  end

  def change_audit_defaults(tables, from:, to:)
    tables.each do |table|
      change_column_default_if_exists(table, :event_id, from: from, to: to)
      change_column_default_if_exists(table, :level_id, from: from, to: to)
    end
  end

  def change_column_default_if_exists(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    change_column_default table, column, from: from, to: to
  end
end
