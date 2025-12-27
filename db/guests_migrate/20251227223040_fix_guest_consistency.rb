# frozen_string_literal: true

class FixGuestConsistency < ActiveRecord::Migration[8.2]
  def change
    %i(org com app).each do |prefix|
      # Status Nullify
      remove_foreign_key "#{prefix}_contacts", "#{prefix}_contact_statuses", column: :status_id, if_exists: true
      add_foreign_key "#{prefix}_contacts", "#{prefix}_contact_statuses", column: :status_id, on_delete: :nullify

      # Category Nullify
      remove_foreign_key "#{prefix}_contacts", "#{prefix}_contact_categories", column: :category_id, if_exists: true
      add_foreign_key "#{prefix}_contacts", "#{prefix}_contact_categories", column: :category_id, on_delete: :nullify
    end

    # Com unique indexes
    remove_index :com_contact_emails, :com_contact_id, if_exists: true
    add_index :com_contact_emails, :com_contact_id, unique: true

    remove_index :com_contact_telephones, :com_contact_id, if_exists: true
    add_index :com_contact_telephones, :com_contact_id, unique: true
  end
end
