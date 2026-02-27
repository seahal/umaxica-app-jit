# frozen_string_literal: true

class ReplaceNoneWithNeyoInOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    occurrence_tables = %w(
      area_occurrences domain_occurrences email_occurrences
      ip_occurrences telephone_occurrences zip_occurrences
      staff_occurrences user_occurrences
    )

    occurrence_tables.each do |table|
      update_status_id(table, from: "NONE", to: "NEYO")
      change_status_default(table, from: "NONE", to: "NEYO")
    end
  end

  def down
    occurrence_tables = %w(
      area_occurrences domain_occurrences email_occurrences
      ip_occurrences telephone_occurrences zip_occurrences
      staff_occurrences user_occurrences
    )

    occurrence_tables.each do |table|
      update_status_id(table, from: "NEYO", to: "NONE")
      change_status_default(table, from: "NEYO", to: "NONE")
    end
  end

  private

  def update_status_id(table, from:, to:)
    return unless table_exists?(table) && column_exists?(table, :status_id)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET status_id = '#{to}'
        WHERE status_id = '#{from}'
      SQL
    end
  end

  def change_status_default(table, from:, to:)
    return unless table_exists?(table) && column_exists?(table, :status_id)

    change_column_default table, :status_id, from: from, to: to
  end
end
