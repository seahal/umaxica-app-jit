# frozen_string_literal: true

class AddRequiredDocumentStatuses < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      %w(app com org).each do |prefix|
        table_name = "#{prefix}_document_statuses"
        seed_statuses(table_name)
      end
    end
  end

  def down
    # No-op to avoid removing reference data used by existing records
  end

  private

  def seed_statuses(table_name)
    return unless table_exists?(table_name)

    statuses = %w(NEYO ACTIVE DRAFT ARCHIVED PUBLISHED)

    statuses.each_with_index do |status_id, index|
      execute <<~SQL.squish
        INSERT INTO #{table_name} (id, position, created_at, updated_at)
        VALUES ('#{status_id}', #{index}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
