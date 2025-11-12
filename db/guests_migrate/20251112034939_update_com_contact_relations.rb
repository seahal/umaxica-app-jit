class UpdateComContactRelations < ActiveRecord::Migration[8.2]
  def up
    # Remove old foreign key columns from com_contacts
    change_table :com_contacts, bulk: true do |t|
      t.remove :com_contact_email_id
      t.remove :com_contact_telephone_id
    end

    # Add new foreign key columns to com_contact_emails and com_contact_telephones
    add_column :com_contact_emails, :com_contact_id, :uuid
    add_column :com_contact_telephones, :com_contact_id, :uuid

    # Add indexes for the new foreign keys
    add_index :com_contact_emails, :com_contact_id
    add_index :com_contact_telephones, :com_contact_id
  end

  def down
    # Remove the new foreign key columns
    remove_index :com_contact_emails, :com_contact_id
    remove_index :com_contact_telephones, :com_contact_id
    remove_column :com_contact_emails, :com_contact_id
    remove_column :com_contact_telephones, :com_contact_id

    # Add back the old foreign key columns
    change_table :com_contacts, bulk: true do |t|
      t.string :com_contact_email_id
      t.string :com_contact_telephone_id
    end
  end
end
