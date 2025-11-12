class UpdateComContactRelations < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # Remove old foreign key columns from com_contacts
    change_table :com_contacts, bulk: true do |t|
      t.remove :com_contact_email_id, type: :string
      t.remove :com_contact_telephone_id, type: :string
    end

    # Add new foreign key columns to com_contact_emails and com_contact_telephones
    # Use default: -> { 'gen_random_uuid()' } to allow existing rows
    add_column :com_contact_emails, :com_contact_id, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_column :com_contact_telephones, :com_contact_id, :uuid, null: false,
default: -> { "gen_random_uuid()" }

    # Add indexes for the new foreign keys
    add_index :com_contact_emails, :com_contact_id
    add_index :com_contact_telephones, :com_contact_id
  end
end
