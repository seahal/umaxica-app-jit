# frozen_string_literal: true

class RestoreGuestContactFkDefaults < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  CATEGORY_TABLES = %w(
    app_contact_categories
    com_contact_categories
    org_contact_categories
  ).freeze

  STATUS_TABLES = %w(
    app_contact_statuses
    com_contact_statuses
    org_contact_statuses
  ).freeze

  CONTACT_TABLES = %w(
    app_contacts
    com_contacts
    org_contacts
  ).freeze

  def up
    safety_assured do
      seed_neyo_ids
      CONTACT_TABLES.each do |table|
        update_fk_defaults(table, :category_id)
        update_fk_defaults(table, :status_id)
      end
    end
  end

  def down
    # No-op to avoid reintroducing invalid defaults.
  end

  private

  def seed_neyo_ids
    (CATEGORY_TABLES + STATUS_TABLES).each do |table|
      seed_id(table, "NEYO")
    end
  end

  def update_fk_defaults(table_name, column)
    return unless table_exists?(table_name) && column_exists?(table_name, column)

    execute <<~SQL.squish
      UPDATE #{table_name}
      SET #{column} = 'NEYO'
      WHERE #{column} = '' OR #{column} IS NULL
    SQL

    change_column_default table_name, column, from: "", to: "NEYO"
  end

  def seed_id(table_name, id)
    return unless table_exists?(table_name)

    cols = ["id"]
    vals = [connection.quote(id)]

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
