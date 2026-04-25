# frozen_string_literal: true

class ValidateCreateAppContacts < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :app_contacts, :app_contact_categories
    validate_foreign_key :app_contacts, :app_contact_statuses
  end
end
