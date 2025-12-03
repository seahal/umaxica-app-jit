class AddHotpColumnsToComContactEmails < ActiveRecord::Migration[8.2]
  def change
    add_column :com_contact_emails, :hotp_secret, :string
    add_column :com_contact_emails, :hotp_counter, :integer
  end
end
