# frozen_string_literal: true

class FixGuestConsistency < ActiveRecord::Migration[8.2]
  def change
    # Org unique indexes
    safety_assured { remove_foreign_key("org_contacts", "org_contact_statuses", column: :status_id, if_exists: true) }
    add_foreign_key("org_contacts", "org_contact_statuses", column: :status_id, on_delete: :nullify, validate: false)

    safety_assured { remove_foreign_key("org_contacts", "org_contact_categories", column: :category_id, if_exists: true) }
    add_foreign_key("org_contacts", "org_contact_categories", column: :category_id, on_delete: :nullify, validate: false)

    # Com unique indexes
    safety_assured { remove_foreign_key("com_contacts", "com_contact_statuses", column: :status_id, if_exists: true) }
    add_foreign_key("com_contacts", "com_contact_statuses", column: :status_id, on_delete: :nullify, validate: false)

    safety_assured { remove_foreign_key("com_contacts", "com_contact_categories", column: :category_id, if_exists: true) }
    add_foreign_key("com_contacts", "com_contact_categories", column: :category_id, on_delete: :nullify, validate: false)

    # App unique indexes
    safety_assured { remove_foreign_key("app_contacts", "app_contact_statuses", column: :status_id, if_exists: true) }
    add_foreign_key("app_contacts", "app_contact_statuses", column: :status_id, on_delete: :nullify, validate: false)

    safety_assured { remove_foreign_key("app_contacts", "app_contact_categories", column: :category_id, if_exists: true) }
    add_foreign_key("app_contacts", "app_contact_categories", column: :category_id, on_delete: :nullify, validate: false)

    # Email/Telephone unique indexes
    safety_assured { remove_index(:com_contact_emails, :com_contact_id, if_exists: true) }
    safety_assured { add_index(:com_contact_emails, :com_contact_id, unique: true) }

    safety_assured { remove_index(:com_contact_telephones, :com_contact_id, if_exists: true) }
    safety_assured { add_index(:com_contact_telephones, :com_contact_id, unique: true) }
  end
end
