# frozen_string_literal: true

class ReplaceNoneWithNeyoInDocumentStatuses < ActiveRecord::Migration[7.1]
  def up
    %w(app com org).each do |prefix|
      status_table = "#{prefix}_document_statuses"
      document_table = "#{prefix}_documents"

      insert_status(status_table, "NEYO")
      update_status_id(document_table, from: "NONE", to: "NEYO")
      change_status_default(document_table, from: "NONE", to: "NEYO")
      delete_status(status_table, "NONE")
    end
  end

  def down
    %w(app com org).each do |prefix|
      status_table = "#{prefix}_document_statuses"
      document_table = "#{prefix}_documents"

      insert_status(status_table, "NONE")
      update_status_id(document_table, from: "NEYO", to: "NONE")
      change_status_default(document_table, from: "NEYO", to: "NONE")
      delete_status(status_table, "NEYO")
    end
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
