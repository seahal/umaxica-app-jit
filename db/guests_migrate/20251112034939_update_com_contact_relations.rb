class UpdateComContactRelations < ActiveRecord::Migration[8.2]
  def up
    add_column :com_contact_emails, :com_contact_id, :uuid
    add_column :com_contact_telephones, :com_contact_id, :uuid

    add_index :com_contact_emails, :com_contact_id
    add_index :com_contact_telephones, :com_contact_id

    backfill_email_contact_ids
    backfill_telephone_contact_ids

    change_column_null :com_contact_emails, :com_contact_id, false
    change_column_null :com_contact_telephones, :com_contact_id, false

    change_table :com_contacts, bulk: true do |t|
      t.remove :com_contact_email_id
      t.remove :com_contact_telephone_id
    end
  end

  def down
    change_table :com_contacts, bulk: true do |t|
      t.string :com_contact_email_id
      t.string :com_contact_telephone_id
    end

    execute <<~SQL.squish
      UPDATE com_contacts
      SET com_contact_email_id = com_contact_emails.id::text
      FROM com_contact_emails
      WHERE com_contact_emails.com_contact_id = com_contacts.id
    SQL

    execute <<~SQL.squish
      UPDATE com_contacts
      SET com_contact_telephone_id = com_contact_telephones.id::text
      FROM com_contact_telephones
      WHERE com_contact_telephones.com_contact_id = com_contacts.id
    SQL

    remove_index :com_contact_emails, :com_contact_id
    remove_index :com_contact_telephones, :com_contact_id

    remove_column :com_contact_emails, :com_contact_id
    remove_column :com_contact_telephones, :com_contact_id
  end

  private

    def backfill_email_contact_ids
      execute <<~SQL.squish
        UPDATE com_contact_emails
        SET com_contact_id = contacts.id
        FROM com_contacts contacts
        WHERE contacts.com_contact_email_id = com_contact_emails.id::text
      SQL
    end

    def backfill_telephone_contact_ids
      execute <<~SQL.squish
        UPDATE com_contact_telephones
        SET com_contact_id = contacts.id
        FROM com_contacts contacts
        WHERE contacts.com_contact_telephone_id = com_contact_telephones.id::text
      SQL
    end
end
