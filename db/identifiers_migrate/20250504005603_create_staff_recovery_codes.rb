class CreateStaffRecoveryCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_recovery_codes, id: :uuid do |t|
      t.uuid :staff_id
      t.string :recovery_code_digest
      t.date :expires_in
      t.timestamps
    end
  end
end
