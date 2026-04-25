# frozen_string_literal: true

class CreateAdminMessages < ActiveRecord::Migration[8.2]
  def change
    create_table(:admin_messages) do |t|
      t.bigint(:staff_message_id)
      t.string(:public_id, null: false, default: "")

      t.timestamps
    end

    add_index(:admin_messages, :staff_message_id, if_not_exists: true)
  end
end
