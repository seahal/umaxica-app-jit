class CreateStaffEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_emails, id: :binary do |t|
      t.string :address
      t.timestamps
    end
  end
end
