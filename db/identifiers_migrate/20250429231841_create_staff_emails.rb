class CreateStaffEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_emails, id: :uuid do |t|
      t.references :staff
      t.string :address
      t.timestamps
    end
  end
end
