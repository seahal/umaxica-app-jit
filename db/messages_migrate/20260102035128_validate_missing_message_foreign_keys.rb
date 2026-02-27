# frozen_string_literal: true

class ValidateMissingMessageForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_message_fk(
      :client_messages, :user_messages,
      column: :user_message_id,
    )
    validate_message_fk(
      :admin_messages, :staff_messages,
      column: :staff_message_id,
    )
  end

  private

  def validate_message_fk(from_table, to_table, column:)
    return unless foreign_key_exists?(from_table, to_table, column: column)

    validate_foreign_key from_table, to_table
  end
end
