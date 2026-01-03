# frozen_string_literal: true

class FixContactCategoryFkBehaviors < ActiveRecord::Migration[8.2]
  def change
    add_contact_fk(:org_contacts, :org_contact_categories)

    add_contact_fk(:com_contacts, :com_contact_categories)

    add_contact_fk(:app_contacts, :app_contact_categories)
  end

  private

  def add_contact_fk(from_table, to_table)
    return if foreign_key_exists?(from_table, to_table, column: :category_id)

    add_foreign_key from_table, to_table,
                    column: :category_id,
                    primary_key: :id,
                    on_delete: :restrict,
                    validate: false
  end
end
