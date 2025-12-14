# frozen_string_literal: true

class UppercaseContactStatusesAndCategories < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        # Uppercase all contact status titles
        execute("UPDATE app_contact_statuses SET title = UPPER(title) WHERE title != UPPER(title)")
        execute("UPDATE com_contact_statuses SET title = UPPER(title) WHERE title != UPPER(title)")
        execute("UPDATE org_contact_statuses SET title = UPPER(title) WHERE title != UPPER(title)")

        # Uppercase all contact category titles
        execute("UPDATE app_contact_categories SET title = UPPER(title) WHERE title != UPPER(title)")
        execute("UPDATE com_contact_categories SET title = UPPER(title) WHERE title != UPPER(title)")
        execute("UPDATE org_contact_categories SET title = UPPER(title) WHERE title != UPPER(title)")

        # Uppercase foreign key references in contacts
        execute("UPDATE app_contacts SET contact_status_title = UPPER(contact_status_title) WHERE contact_status_title IS NOT NULL AND contact_status_title != UPPER(contact_status_title)")
        execute("UPDATE app_contacts SET contact_category_title = UPPER(contact_category_title) WHERE contact_category_title IS NOT NULL AND contact_category_title != UPPER(contact_category_title)")

        execute("UPDATE com_contacts SET contact_status_title = UPPER(contact_status_title) WHERE contact_status_title IS NOT NULL AND contact_status_title != UPPER(contact_status_title)")
        execute("UPDATE com_contacts SET contact_category_title = UPPER(contact_category_title) WHERE contact_category_title IS NOT NULL AND contact_category_title != UPPER(contact_category_title)")

        execute("UPDATE org_contacts SET contact_status_title = UPPER(contact_status_title) WHERE contact_status_title IS NOT NULL AND contact_status_title != UPPER(contact_status_title)")
        execute("UPDATE org_contacts SET contact_category_title = UPPER(contact_category_title) WHERE contact_category_title IS NOT NULL AND contact_category_title != UPPER(contact_category_title)")
      end

      dir.down do
        # Reversing would be complex and data lossy, so we don't support down migration
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
