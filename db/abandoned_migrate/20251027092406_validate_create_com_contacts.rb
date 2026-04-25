# frozen_string_literal: true

class ValidateCreateComContacts < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :com_contacts, :com_contact_categories
    validate_foreign_key :com_contacts, :com_contact_statuses
    validate_foreign_key :com_contacts, :com_contact_emails
    validate_foreign_key :com_contacts, :com_contact_telephones
  end
end
