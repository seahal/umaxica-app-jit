# frozen_string_literal: true

class FixConsistencyContacts < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Clear data to allow NOT NULL constraints easily
      target_tables = %w(
        org_contacts org_contact_telephones org_contact_emails org_contact_topics
        com_contacts com_contact_telephones com_contact_emails com_contact_topics
        app_contacts app_contact_telephones app_contact_emails app_contact_topics
      )
      # Check existence before truncate to be safe
      existing_tables = target_tables.select { |t| table_exists?(t) }
      execute("TRUNCATE TABLE #{existing_tables.join(", ")} CASCADE") if existing_tables.any?

      # --- OrgContact ---
      # Fix category_id (String -> Bigint FK)
      remove_column(:org_contacts, :category_id) if column_exists?(:org_contacts, :category_id)
      add_column(:org_contacts, :category_id, :bigint, null: false, default: 0)
      add_foreign_key(:org_contacts, :org_contact_categories, column: :category_id)
      add_index(:org_contacts, :category_id)

      # Fix status_id (Int(2) -> Bigint FK)
      change_column(:org_contacts, :status_id, :bigint)
      add_foreign_key(:org_contacts, :org_contact_statuses, column: :status_id)

      # --- OrgContactTelephone ---
      add_column(:org_contact_telephones, :org_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:org_contact_telephones, :org_contacts)
      add_index(:org_contact_telephones, :org_contact_id)

      # --- OrgContactEmail ---
      add_column(:org_contact_emails, :org_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:org_contact_emails, :org_contacts)
      add_index(:org_contact_emails, :org_contact_id)

      # --- ComContact ---
      remove_column(:com_contacts, :category_id) if column_exists?(:com_contacts, :category_id)
      add_column(:com_contacts, :category_id, :bigint, null: false, default: 0)
      add_foreign_key(:com_contacts, :com_contact_categories, column: :category_id)
      add_index(:com_contacts, :category_id)

      change_column(:com_contacts, :status_id, :bigint)
      add_foreign_key(:com_contacts, :com_contact_statuses, column: :status_id)

      add_column(:com_contact_telephones, :com_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:com_contact_telephones, :com_contacts)
      add_index(:com_contact_telephones, :com_contact_id)
      add_column(:com_contact_emails, :com_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:com_contact_emails, :com_contacts)
      add_index(:com_contact_emails, :com_contact_id)

      # --- AppContact ---
      remove_column(:app_contacts, :category_id) if column_exists?(:app_contacts, :category_id)
      add_column(:app_contacts, :category_id, :bigint, null: false, default: 0)
      add_foreign_key(:app_contacts, :app_contact_categories, column: :category_id)
      add_index(:app_contacts, :category_id)

      change_column(:app_contacts, :status_id, :bigint)
      add_foreign_key(:app_contacts, :app_contact_statuses, column: :status_id)

      add_column(:app_contact_telephones, :app_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:app_contact_telephones, :app_contacts)
      add_index(:app_contact_telephones, :app_contact_id)
      add_column(:app_contact_emails, :app_contact_id, :bigint, null: false, default: 0)
      add_foreign_key(:app_contact_emails, :app_contacts)
      add_index(:app_contact_emails, :app_contact_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
