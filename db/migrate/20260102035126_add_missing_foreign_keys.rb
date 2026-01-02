# frozen_string_literal: true

class AddMissingForeignKeys < ActiveRecord::Migration[8.2]
  def change
    # Add foreign keys for polymorphic-style associations
    add_foreign_key :client_notifications, :user_notifications,
                    column: :user_notification_id

    add_foreign_key :admin_notifications, :staff_notifications,
                    column: :staff_notification_id

    add_foreign_key :client_messages, :user_messages,
                    column: :user_message_id

    add_foreign_key :admin_messages, :staff_messages,
                    column: :staff_message_id

    # Add foreign key for post versions
    add_foreign_key :post_versions, :posts,
                    column: :post_id

    # Add foreign key for self-referential division parent
    add_foreign_key :divisions, :divisions,
                    column: :parent_id
  end
end
