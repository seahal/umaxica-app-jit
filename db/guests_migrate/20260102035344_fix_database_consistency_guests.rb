# frozen_string_literal: true

class FixDatabaseConsistencyGuests < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # Add NOT NULL constraints to contact status foreign keys using safe approach
    add_check_constraint :org_contacts, "status_id IS NOT NULL",
                         name: "org_contacts_status_id_null", validate: false
    validate_check_constraint :org_contacts, name: "org_contacts_status_id_null"
    change_column_null :org_contacts, :status_id, false
    remove_check_constraint :org_contacts, name: "org_contacts_status_id_null"

    add_check_constraint :com_contacts, "status_id IS NOT NULL",
                         name: "com_contacts_status_id_null", validate: false
    validate_check_constraint :com_contacts, name: "com_contacts_status_id_null"
    change_column_null :com_contacts, :status_id, false
    remove_check_constraint :com_contacts, name: "com_contacts_status_id_null"

    add_check_constraint :app_contacts, "status_id IS NOT NULL",
                         name: "app_contacts_status_id_null", validate: false
    validate_check_constraint :app_contacts, name: "app_contacts_status_id_null"
    change_column_null :app_contacts, :status_id, false
    remove_check_constraint :app_contacts, name: "app_contacts_status_id_null"

    # Add foreign keys with restrict behavior for contact categories (without validation first)
    unless foreign_key_exists?(:org_contacts, :org_contact_categories, column: :category_id)
      add_foreign_key :org_contacts, :org_contact_categories,
                      column: :category_id,
                      primary_key: :id,
                      on_delete: :restrict,
                      validate: false
      validate_foreign_key :org_contacts, :org_contact_categories
    end

    unless foreign_key_exists?(:com_contacts, :com_contact_categories, column: :category_id)
      add_foreign_key :com_contacts, :com_contact_categories,
                      column: :category_id,
                      primary_key: :id,
                      on_delete: :restrict,
                      validate: false
      validate_foreign_key :com_contacts, :com_contact_categories
    end

    unless foreign_key_exists?(:app_contacts, :app_contact_categories, column: :category_id)
      add_foreign_key :app_contacts, :app_contact_categories,
                      column: :category_id,
                      primary_key: :id,
                      on_delete: :restrict,
                      validate: false
      validate_foreign_key :app_contacts, :app_contact_categories
    end
  end

  def down
    remove_foreign_key :app_contacts, :app_contact_categories
    remove_foreign_key :com_contacts, :com_contact_categories
    remove_foreign_key :org_contacts, :org_contact_categories

    change_column_null :app_contacts, :status_id, true
    change_column_null :com_contacts, :status_id, true
    change_column_null :org_contacts, :status_id, true
  end
end
