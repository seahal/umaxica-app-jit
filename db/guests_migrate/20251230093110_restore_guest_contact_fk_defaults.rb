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

  def update_fk_defaults(table_name, column)
    return unless table_exists?(table_name) && column_exists?(table_name, column)

    execute <<~SQL.squish
      UPDATE #{table_name}
      SET #{column} = 'NEYO'
      WHERE #{column} = '' OR #{column} IS NULL
    SQL

    change_column_default table_name, column, from: "", to: "NEYO"
  end
end
