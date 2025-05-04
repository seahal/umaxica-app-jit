class CreateStaffRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_recovery_codes do |t|
      t.string :password_digest
      t.date :expire_in

      t.timestamps
    end
  end
end
