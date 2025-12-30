# frozen_string_literal: true

class SeedTestGuestReferenceIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  NEYO_STATUS_TABLES = %w(
    app_contact_categories
    app_contact_statuses
    org_contact_categories
    org_contact_statuses
    com_contact_categories
    com_contact_statuses
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

    # Handle parent_id: app_contact_categories uses NIL_UUID, others use empty string
    if column_exists?(table_name, :parent_id)
      cols << "parent_id"
      vals << if table_name == "app_contact_categories"
        connection.quote("00000000-0000-0000-0000-000000000000")
      else
        connection.quote("")
      end
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
