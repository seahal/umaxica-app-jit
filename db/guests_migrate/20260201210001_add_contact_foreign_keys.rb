# frozen_string_literal: true

# Migration to add foreign keys for contact associations
# This resolves ForeignKeyChecker warnings for contact category and status associations
class AddContactForeignKeys < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # App Contacts
    add_contact_foreign_key(:app_contacts, :app_contact_categories, :category_id)
    add_contact_foreign_key(:app_contacts, :app_contact_statuses, :status_id)
    add_contact_index(:app_contacts, :category_id, "index_app_contacts_on_category_id")
    add_contact_index(:app_contacts, :status_id, "index_app_contacts_on_status_id")

    # Com Contacts
    add_contact_foreign_key(:com_contacts, :com_contact_categories, :category_id)
    add_contact_foreign_key(:com_contacts, :com_contact_statuses, :status_id)
    add_contact_index(:com_contacts, :category_id, "index_com_contacts_on_category_id")
    add_contact_index(:com_contacts, :status_id, "index_com_contacts_on_status_id")

    # Org Contacts
    add_contact_foreign_key(:org_contacts, :org_contact_categories, :category_id)
    add_contact_foreign_key(:org_contacts, :org_contact_statuses, :status_id)
    add_contact_index(:org_contacts, :category_id, "index_org_contacts_on_category_id")
    add_contact_index(:org_contacts, :status_id, "index_org_contacts_on_status_id")
  end

  private

  def add_contact_foreign_key(from_table, to_table, column)
    return unless column_exists?(from_table, column)
    return unless column_exists?(to_table, :id)
    return if foreign_key_exists?(from_table, to_table, column: column)
    return unless compatible_column_types?(from_table, column, to_table, :id)

    add_foreign_key(
      from_table, to_table,
      column: column,
      on_delete: :restrict,
      validate: false,
    )
  end

  def add_contact_index(table, column, name)
    return unless column_exists?(table, column)
    return if index_exists?(table, column, name: name)

    add_index(
      table, column,
      name: name,
      algorithm: :concurrently,
    )
  end

  def compatible_column_types?(from_table, from_column, to_table, to_column)
    from_sql_type = connection.columns(from_table).find { |column| column.name == from_column.to_s }&.sql_type
    to_sql_type = connection.columns(to_table).find { |column| column.name == to_column.to_s }&.sql_type

    from_sql_type == to_sql_type
  end
end
