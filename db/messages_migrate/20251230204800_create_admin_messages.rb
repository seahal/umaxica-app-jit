# frozen_string_literal: true

class CreateAdminMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :admin_messages, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :staff_message_id
      t.uuid :public_id

      t.timestamps
    end

    add_index :admin_messages, :staff_message_id, if_not_exists: true
  end
end
