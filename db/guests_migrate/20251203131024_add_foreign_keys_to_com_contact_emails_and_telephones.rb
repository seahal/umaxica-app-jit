class AddForeignKeysToComContactEmailsAndTelephones < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :com_contact_emails, :com_contacts
    add_foreign_key :com_contact_telephones, :com_contacts
  end
end
