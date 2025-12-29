# frozen_string_literal: true

class ReplaceNoneWithNeyoInOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def up
    status_tables = %w(
      area_occurrence_statuses domain_occurrence_statuses email_occurrence_statuses
      ip_occurrence_statuses telephone_occurrence_statuses zip_occurrence_statuses
      staff_occurrence_statuses user_occurrence_statuses
    )

    occurrence_tables = %w(
      area_occurrences domain_occurrences email_occurrences
      ip_occurrences telephone_occurrences zip_occurrences
      staff_occurrences user_occurrences
    )

    status_tables.each { |table| insert_status(table, "NEYO") }
    occurrence_tables.each do |table|
      update_status_id(table, from: "NONE", to: "NEYO")
      change_status_default(table, from: "NONE", to: "NEYO")
    end
    status_tables.each { |table| delete_status(table, "NONE") }
  end

  def down
    status_tables = %w(
      area_occurrence_statuses domain_occurrence_statuses email_occurrence_statuses
      ip_occurrence_statuses telephone_occurrence_statuses zip_occurrence_statuses
      staff_occurrence_statuses user_occurrence_statuses
    )

    occurrence_tables = %w(
      area_occurrences domain_occurrences email_occurrences
      ip_occurrences telephone_occurrences zip_occurrences
      staff_occurrences user_occurrences
    )

    status_tables.each { |table| insert_status(table, "NONE") }
    occurrence_tables.each do |table|
      update_status_id(table, from: "NEYO", to: "NONE")
      change_status_default(table, from: "NEYO", to: "NONE")
    end
    status_tables.each { |table| delete_status(table, "NEYO") }
  end

  private

  def insert_status(table, id)
    return unless table_exists?(table)

    cols = [:id]
    vals = [id]

    if column_exists?(table, :active)
      cols << :active
      vals << true
    end

    if column_exists?(table, :position)
      cols << :position
      vals << 0
    end

    if column_exists?(table, :description)
      cols << :description
      vals << id
    end

    if column_exists?(table, :expires_at)
      cols << :expires_at
      vals << (1.day.from_now)
    end

    if column_exists?(table, :created_at)
      cols << :created_at
      vals << Time.current
    end

    if column_exists?(table, :updated_at)
      cols << :updated_at
      vals << Time.current
    end

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (#{cols.join(", ")})
        VALUES (#{vals.map { |v| connection.quote(v) }.join(", ")})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

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

  def delete_status(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE id = '#{id}'
      SQL
    end
  end
end
