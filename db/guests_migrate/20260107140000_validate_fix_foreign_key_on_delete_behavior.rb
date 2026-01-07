# frozen_string_literal: true

class ValidateFixForeignKeyOnDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :app_contacts, :app_contact_categories, column: :category_id
    validate_foreign_key :app_contacts, :app_contact_statuses, column: :status_id

    validate_foreign_key :com_contacts, :com_contact_categories, column: :category_id
    validate_foreign_key :com_contacts, :com_contact_statuses, column: :status_id

    validate_foreign_key :org_contacts, :org_contact_categories, column: :category_id
    validate_foreign_key :org_contacts, :org_contact_statuses, column: :status_id
  end
end
