# frozen_string_literal: true

class FixDatabaseConsistencyMessage < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # Add NOT NULL constraint to user_messages.user_id using safe approach
    add_check_constraint :user_messages, "user_id IS NOT NULL",
                         name: "user_messages_user_id_null", validate: false
    validate_check_constraint :user_messages, name: "user_messages_user_id_null"
    change_column_null :user_messages, :user_id, false
    remove_check_constraint :user_messages, name: "user_messages_user_id_null"

    # Add foreign keys for message associations
    unless foreign_key_exists?(:client_messages, :user_messages, column: :user_message_id)
      add_foreign_key :client_messages, :user_messages,
                      column: :user_message_id,
                      validate: false
      validate_foreign_key :client_messages, :user_messages
    end

    unless foreign_key_exists?(:admin_messages, :staff_messages, column: :staff_message_id)
      add_foreign_key :admin_messages, :staff_messages,
                      column: :staff_message_id,
                      validate: false
      validate_foreign_key :admin_messages, :staff_messages
    end
  end

  def down
    remove_foreign_key :admin_messages, :staff_messages
    remove_foreign_key :client_messages, :user_messages

    change_column_null :user_messages, :user_id, true
  end
end
