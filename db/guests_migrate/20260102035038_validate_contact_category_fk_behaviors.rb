# frozen_string_literal: true

class ValidateContactCategoryFkBehaviors < ActiveRecord::Migration[8.2]
  def change
    validate_contact_fk(:org_contacts, :org_contact_categories)
    validate_contact_fk(:com_contacts, :com_contact_categories)
    validate_contact_fk(:app_contacts, :app_contact_categories)
  end

  private

  def validate_contact_fk(from_table, to_table)
    return unless foreign_key_exists?(from_table, to_table, column: :category_id)

    validate_foreign_key from_table, to_table
  end
end
