# frozen_string_literal: true

class AddNotNullToUserMessagesUserId < ActiveRecord::Migration[8.2]
  def change
    add_check_constraint :user_messages, "user_id IS NOT NULL",
                         name: "user_messages_user_id_null",
                         validate: false
  end
end
