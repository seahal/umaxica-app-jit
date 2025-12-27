# frozen_string_literal: true

class CreateStaffTokens < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_tokens, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :staff_id, null: false
      t.timestamps
    end
  end
end
