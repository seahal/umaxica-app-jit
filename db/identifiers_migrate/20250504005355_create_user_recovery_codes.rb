class CreateUserRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recovery_codes, id: :uuid do |t|
      t.string :password_digest
      t.date :expires_in
      t.timestamps
    end
  end
end
