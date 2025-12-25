class CreateStaffUserOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_user_occurrences, id: :uuid do |t|
      t.references :staff_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :user_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
