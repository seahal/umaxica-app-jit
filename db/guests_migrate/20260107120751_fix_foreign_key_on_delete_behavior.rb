# frozen_string_literal: true

class FixForeignKeyOnDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    # AppContact
    remove_foreign_key(:app_contacts, :app_contact_categories, column: :category_id)
    remove_foreign_key(:app_contacts, :app_contact_statuses, column: :status_id)
    add_foreign_key(:app_contacts, :app_contact_categories, column: :category_id, on_delete: :cascade, validate: false)
    add_foreign_key(:app_contacts, :app_contact_statuses, column: :status_id, on_delete: :cascade, validate: false)

    # ComContact
    remove_foreign_key(:com_contacts, :com_contact_categories, column: :category_id)
    remove_foreign_key(:com_contacts, :com_contact_statuses, column: :status_id)
    add_foreign_key(:com_contacts, :com_contact_categories, column: :category_id, on_delete: :cascade, validate: false)
    add_foreign_key(:com_contacts, :com_contact_statuses, column: :status_id, on_delete: :cascade, validate: false)

    # OrgContact
    remove_foreign_key(:org_contacts, :org_contact_categories, column: :category_id)
    remove_foreign_key(:org_contacts, :org_contact_statuses, column: :status_id)
    add_foreign_key(:org_contacts, :org_contact_categories, column: :category_id, on_delete: :cascade, validate: false)
    add_foreign_key(:org_contacts, :org_contact_statuses, column: :status_id, on_delete: :cascade, validate: false)
  end
end
