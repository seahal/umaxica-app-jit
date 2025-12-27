# frozen_string_literal: true

class AddGuestIndexesAndFks < ActiveRecord::Migration[8.2]
  def change
    # Lower ID Unique Indexes for Status Tables
    add_index :org_contact_statuses, "lower(id)", unique: true, name: "index_org_contact_statuses_on_lower_id", if_not_exists: true
    add_index :org_contact_categories, "lower(id)", unique: true, name: "index_org_contact_categories_on_lower_id", if_not_exists: true
    add_index :com_contact_statuses, "lower(id)", unique: true, name: "index_com_contact_statuses_on_lower_id", if_not_exists: true
    add_index :com_contact_categories, "lower(id)", unique: true, name: "index_com_contact_categories_on_lower_id", if_not_exists: true
    add_index :app_contact_statuses, "lower(id)", unique: true, name: "index_app_contact_statuses_on_lower_id", if_not_exists: true
    add_index :app_contact_categories, "lower(id)", unique: true, name: "index_app_contact_categories_on_lower_id", if_not_exists: true

    # Contact Foreign Keys
    add_foreign_key :com_contact_telephones, :com_contacts, if_not_exists: true
    add_foreign_key :com_contact_emails, :com_contacts, if_not_exists: true
    add_foreign_key :org_contact_telephones, :org_contacts, if_not_exists: true
    add_foreign_key :org_contact_emails, :org_contacts, if_not_exists: true
    add_foreign_key :app_contact_telephones, :app_contacts, if_not_exists: true
    add_foreign_key :app_contact_emails, :app_contacts, if_not_exists: true
  end
end
