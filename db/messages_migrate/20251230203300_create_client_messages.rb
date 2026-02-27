# frozen_string_literal: true

class CreateClientMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :client_messages do |t|
      t.bigint :user_message_id
      t.string :public_id, null: false, default: ""

      t.timestamps
    end

    add_index :client_messages, :user_message_id, if_not_exists: true
  end
end
