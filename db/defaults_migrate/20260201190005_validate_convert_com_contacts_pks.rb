# frozen_string_literal: true

class ValidateConvertComContactsPks < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    if foreign_key_exists?(:com_contacts, column: :category_id, to_table: :com_contact_categories)
      validate_foreign_key "com_contacts", "com_contact_categories"
    end

    if foreign_key_exists?(:com_contacts, column: :status_id, to_table: :com_contact_statuses)
      validate_foreign_key "com_contacts", "com_contact_statuses"
    end

    if foreign_key_exists?(:com_contact_audits, column: :com_contact_id, to_table: :com_contacts)
      validate_foreign_key "com_contact_audits", "com_contacts"
    end

    if foreign_key_exists?(:com_contact_topics, column: :com_contact_id, to_table: :com_contacts)
      validate_foreign_key "com_contact_topics", "com_contacts"
    end

    if foreign_key_exists?(:com_contact_emails, column: :com_contact_id, to_table: :com_contacts)
      validate_foreign_key "com_contact_emails", "com_contacts"
    end

    return unless foreign_key_exists?(:com_contact_telephones, column: :com_contact_id, to_table: :com_contacts)

    validate_foreign_key "com_contact_telephones", "com_contacts"

  end
end
