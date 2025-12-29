# frozen_string_literal: true

class SeedTestDocumentReferenceIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  NEYO_STATUS_TABLES = %w(
    org_document_statuses
    com_document_statuses
    app_document_statuses
  ).freeze

  def up
    safety_assured do
      NEYO_STATUS_TABLES.each do |table|
        seed_status(table, "NEYO", description: "Default")
      end
    end
  end

  def down
    # No-op to avoid removing shared reference data.
  end

  private

  def seed_status(table_name, id, description:)
    return unless table_exists?(table_name)

    cols = ["id"]
    vals = [connection.quote(id)]

    if column_exists?(table_name, :description)
      cols << "description"
      vals << connection.quote(description)
    end

    if column_exists?(table_name, :active)
      cols << "active"
      vals << "TRUE"
    end

    if column_exists?(table_name, :position)
      cols << "position"
      vals << "0"
    end

    if column_exists?(table_name, :created_at)
      cols << "created_at"
      vals << "CURRENT_TIMESTAMP"
    end

    if column_exists?(table_name, :updated_at)
      cols << "updated_at"
      vals << "CURRENT_TIMESTAMP"
    end

    execute <<~SQL.squish
      INSERT INTO #{table_name} (#{cols.join(", ")})
      VALUES (#{vals.join(", ")})
      ON CONFLICT (id) DO NOTHING
    SQL
  end
end
