class UpdateComContactRelations < ActiveRecord::Migration[8.2]
  def change
    # Remove old foreign key columns from com_contacts
    remove_column :com_contacts, :com_contact_email_id, :string
    remove_column :com_contacts, :com_contact_telephone_id, :string

    # Add new foreign key columns to com_contact_emails and com_contact_telephones
    add_column :com_contact_emails, :com_contact_id, :uuid, null: false
    add_column :com_contact_telephones, :com_contact_id, :uuid, null: false

    # Add indexes for the new foreign keys
    add_index :com_contact_emails, :com_contact_id
    add_index :com_contact_telephones, :com_contact_id
  end
end
