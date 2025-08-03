class CreateStaffTimeBasedOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_time_based_one_time_passwords, id: false do |t|
      t.uuid :staff_id, null: false # , foreign_key: true
      t.uuid :time_based_one_time_password_id, null: false # , foreign_key: true
      t.timestamps
    end
  end
end
