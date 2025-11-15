class AddHotpFieldsToComContactTelephones < ActiveRecord::Migration[8.1]
  def change
    change_table :com_contact_telephones, bulk: true do |t|
      t.string :hotp_secret, limit: 255
      t.integer :hotp_counter
    end
  end
end
