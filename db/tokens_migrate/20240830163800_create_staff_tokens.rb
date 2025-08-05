# frozen_string_literal: true

class CreateStaffTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :staff_tokens, id: :uuid do |t|
      t.uuid :staff_id

      t.timestamps
    end
  end
end
