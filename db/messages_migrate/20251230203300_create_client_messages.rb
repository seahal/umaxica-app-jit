# frozen_string_literal: true

class CreateClientMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :client_messages, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :user_message_id
      t.uuid :public_id

      t.timestamps
    end

    add_index :client_messages, :user_message_id, if_not_exists: true
  end
end
