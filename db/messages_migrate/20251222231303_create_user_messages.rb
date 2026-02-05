# frozen_string_literal: true

class CreateUserMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :user_messages do |t|
      t.bigint :user_id, null: false
      t.string :public_id, null: false, default: ""

      t.timestamps
    end
  end
end
