class CreateStaffTokens < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_tokens, id: :uuid do |t|
      t.uuid :staff_id, null: false
      t.timestamps
    end
  end
end
