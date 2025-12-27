# frozen_string_literal: true

class AddHotpColumnsToComContactEmails < ActiveRecord::Migration[8.2]
  def change
    change_table :com_contact_emails, bulk: true do |t|
      t.string :hotp_secret
      t.integer :hotp_counter
    end
  end
end
