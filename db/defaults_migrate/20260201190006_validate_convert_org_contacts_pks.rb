# frozen_string_literal: true

class ValidateConvertOrgContactsPks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    if foreign_key_exists?(:org_contacts, column: :category_id, to_table: :org_contact_categories)
      validate_foreign_key("org_contacts", "org_contact_categories")
    end

    if foreign_key_exists?(:org_contacts, column: :status_id, to_table: :org_contact_statuses)
      validate_foreign_key("org_contacts", "org_contact_statuses")
    end

    if foreign_key_exists?(:org_contact_topics, column: :org_contact_id, to_table: :org_contacts)
      validate_foreign_key("org_contact_topics", "org_contacts")
    end

    if foreign_key_exists?(:org_contact_emails, column: :org_contact_id, to_table: :org_contacts)
      validate_foreign_key("org_contact_emails", "org_contacts")
    end

    return unless foreign_key_exists?(:org_contact_telephones, column: :org_contact_id, to_table: :org_contacts)

    validate_foreign_key("org_contact_telephones", "org_contacts")

  end
end
