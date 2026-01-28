# frozen_string_literal: true

class ValidateNotNullUserMessagesUserId < ActiveRecord::Migration[8.2]
  def up
    validate_check_constraint :user_messages, name: "user_messages_user_id_null"
    change_column_null :user_messages, :user_id, false
    remove_check_constraint :user_messages, name: "user_messages_user_id_null"
  end

  def down
    add_check_constraint :user_messages, "user_id IS NOT NULL",
                         name: "user_messages_user_id_null",
                         validate: false
    change_column_null :user_messages, :user_id, true
  end
end
