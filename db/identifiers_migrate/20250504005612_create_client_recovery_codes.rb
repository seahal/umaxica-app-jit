class CreateClientRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :client_recovery_codes, id: :uuid do |t|
      t.string :password_digest
      t.date :expires_in
      t.timestamps
    end
  end
end
