# frozen_string_literal: true

class CreateStaffTokens < ActiveRecord::Migration[8.2]
  def change
    create_table(:staff_tokens) do |t|
      t.bigint(:staff_id, null: false)
      t.timestamps
    end
  end
end
