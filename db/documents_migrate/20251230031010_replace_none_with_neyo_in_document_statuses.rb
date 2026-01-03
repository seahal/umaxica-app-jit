# frozen_string_literal: true

class ReplaceNoneWithNeyoInDocumentStatuses < ActiveRecord::Migration[7.1]
  def up
    %w(app com org).each do |prefix|
      document_table = "#{prefix}_documents"

      update_status_id(document_table, from: "NONE", to: "NEYO")
      change_status_default(document_table, from: "NONE", to: "NEYO")
    end
  end

  def down
    %w(app com org).each do |prefix|
      document_table = "#{prefix}_documents"

      update_status_id(document_table, from: "NEYO", to: "NONE")
      change_status_default(document_table, from: "NEYO", to: "NONE")
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
