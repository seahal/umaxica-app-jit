# frozen_string_literal: true

class CreateStaffTokenKinds < ActiveRecord::Migration[8.2]
  def up
    create_table :staff_token_kinds, id: :string do |t|
      t.timestamps null: false
    end
  end

  def down
    drop_table :staff_token_kinds
  end
end
