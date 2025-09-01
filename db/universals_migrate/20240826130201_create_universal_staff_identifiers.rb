# ToDo: Use table partitioning.
class CreateUniversalStaffIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_staff_identifiers, id: :uuid do |t|
      t.string :otp_private_key
      t.datetime :last_otp_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end
end
