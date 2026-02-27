# frozen_string_literal: true

# Migration to add foreign keys for contact associations
# This resolves ForeignKeyChecker warnings for contact category and status associations
class AddContactForeignKeys < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # App Contacts
    add_foreign_key :app_contacts, :app_contact_categories,
                    column: :category_id,
                    on_delete: :restrict,
                    validate: false
    add_foreign_key :app_contacts, :app_contact_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_index :app_contacts, :category_id,
              name: "index_app_contacts_on_category_id",
              algorithm: :concurrently
    add_index :app_contacts, :status_id,
              name: "index_app_contacts_on_status_id",
              algorithm: :concurrently

    # Com Contacts
    add_foreign_key :com_contacts, :com_contact_categories,
                    column: :category_id,
                    on_delete: :restrict,
                    validate: false
    add_foreign_key :com_contacts, :com_contact_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_index :com_contacts, :category_id,
              name: "index_com_contacts_on_category_id",
              algorithm: :concurrently
    add_index :com_contacts, :status_id,
              name: "index_com_contacts_on_status_id",
              algorithm: :concurrently

    # Org Contacts
    add_foreign_key :org_contacts, :org_contact_categories,
                    column: :category_id,
                    on_delete: :restrict,
                    validate: false
    add_foreign_key :org_contacts, :org_contact_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_index :org_contacts, :category_id,
              name: "index_org_contacts_on_category_id",
              algorithm: :concurrently
    add_index :org_contacts, :status_id,
              name: "index_org_contacts_on_status_id",
              algorithm: :concurrently
  end
end
