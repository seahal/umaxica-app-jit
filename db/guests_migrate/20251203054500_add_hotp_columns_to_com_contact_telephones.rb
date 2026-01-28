# frozen_string_literal: true

class AddHotpColumnsToComContactTelephones < ActiveRecord::Migration[8.2]
  def change
    change_table :com_contact_telephones, bulk: true do |t|
      t.string :hotp_secret
      t.integer :hotp_counter
    end
  end
end
