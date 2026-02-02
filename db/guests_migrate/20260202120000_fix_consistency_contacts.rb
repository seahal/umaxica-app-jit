# frozen_string_literal: true

class FixConsistencyContacts < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # rubocop:disable Rails/NotNullColumn
      # Clear data to allow NOT NULL constraints easily
      target_tables = %w(
        org_contacts org_contact_telephones org_contact_emails org_contact_topics
        com_contacts com_contact_telephones com_contact_emails com_contact_topics
        app_contacts app_contact_telephones app_contact_emails app_contact_topics
      )
      # Check existence before truncate to be safe
      existing_tables = target_tables.select { |t| table_exists?(t) }
      execute "TRUNCATE TABLE #{existing_tables.join(", ")} CASCADE" if existing_tables.any?

      # --- OrgContact ---
      # Fix category_id (String -> Bigint FK)
      remove_column :org_contacts, :category_id if column_exists?(:org_contacts, :category_id)
      add_reference :org_contacts, :category, foreign_key: { to_table: :org_contact_categories }, index: true, null: false, type: :bigint

      # Fix status_id (Int(2) -> Bigint FK)
      change_column :org_contacts, :status_id, :bigint
      add_foreign_key :org_contacts, :org_contact_statuses, column: :status_id

      # --- OrgContactTelephone ---
      add_reference :org_contact_telephones, :org_contact, foreign_key: true, index: true, null: false

      # --- OrgContactEmail ---
      add_reference :org_contact_emails, :org_contact, foreign_key: true, index: true, null: false

      # --- ComContact ---
      remove_column :com_contacts, :category_id if column_exists?(:com_contacts, :category_id)
      add_reference :com_contacts, :category, foreign_key: { to_table: :com_contact_categories }, index: true, null: false, type: :bigint

      change_column :com_contacts, :status_id, :bigint
      add_foreign_key :com_contacts, :com_contact_statuses, column: :status_id

      add_reference :com_contact_telephones, :com_contact, foreign_key: true, index: true, null: false
      add_reference :com_contact_emails, :com_contact, foreign_key: true, index: true, null: false

      # --- AppContact ---
      remove_column :app_contacts, :category_id if column_exists?(:app_contacts, :category_id)
      add_reference :app_contacts, :category, foreign_key: { to_table: :app_contact_categories }, index: true, null: false, type: :bigint

      change_column :app_contacts, :status_id, :bigint
      add_foreign_key :app_contacts, :app_contact_statuses, column: :status_id

      add_reference :app_contact_telephones, :app_contact, foreign_key: true, index: true, null: false
      add_reference :app_contact_emails, :app_contact, foreign_key: true, index: true, null: false
      # rubocop:enable Rails/NotNullColumn
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
