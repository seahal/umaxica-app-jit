# frozen_string_literal: true

class CreateStaffMessages < ActiveRecord::Migration[8.2]
  def change
    create_table(:staff_messages) do |t|
      t.bigint(:staff_id, null: false)
      t.string(:public_id, null: false, default: "")

      t.timestamps
    end
  end
end
