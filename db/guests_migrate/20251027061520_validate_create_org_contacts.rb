# frozen_string_literal: true

class ValidateCreateOrgContacts < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :org_contacts, :org_contact_categories
    validate_foreign_key :org_contacts, :org_contact_statuses
  end
end
