class CreateEmailStaffOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :email_staff_occurrences, id: :uuid do |t|
      t.references :email_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :staff_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
