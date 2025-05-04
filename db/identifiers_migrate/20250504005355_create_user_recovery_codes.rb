class CreateUserRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recovery_codes do |t|
      t.string :password_digest
      t.date :expire_in

      t.timestamps
    end
  end
end
