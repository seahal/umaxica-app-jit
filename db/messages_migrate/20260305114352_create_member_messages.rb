# frozen_string_literal: true

class CreateMemberMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :member_messages do |t|
      t.bigint :user_message_id
      t.string :public_id, null: false, default: ""

      t.timestamps
    end

    add_index :member_messages, :public_id, unique: true, if_not_exists: true
    add_index :member_messages, :user_message_id, if_not_exists: true
  end
end
