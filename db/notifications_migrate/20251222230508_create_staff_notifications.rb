# frozen_string_literal: true

class CreateStaffNotifications < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_notifications, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :staff_id
      t.uuid :public_id

      t.timestamps
    end
  end
end
