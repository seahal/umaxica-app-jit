# frozen_string_literal: true

class AddMemberMessageForeignKey < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:member_messages) && table_exists?(:user_messages)
    return if foreign_key_exists?(:member_messages, :user_messages, column: :user_message_id)

    add_foreign_key(
      :member_messages, :user_messages,
      column: :user_message_id, validate: false,
    )
  end
end
