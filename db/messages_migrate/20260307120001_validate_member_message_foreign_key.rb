# frozen_string_literal: true

class ValidateMemberMessageForeignKey < ActiveRecord::Migration[8.2]
  def change
    return unless foreign_key_exists?(:member_messages, :user_messages, column: :user_message_id)

    validate_foreign_key :member_messages, :user_messages
  end
end
