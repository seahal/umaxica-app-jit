# frozen_string_literal: true

class AddMissingMessageForeignKeys < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :client_messages, :user_messages,
                    column: :user_message_id, validate: false

    add_foreign_key :admin_messages, :staff_messages,
                    column: :staff_message_id, validate: false
  end
end
