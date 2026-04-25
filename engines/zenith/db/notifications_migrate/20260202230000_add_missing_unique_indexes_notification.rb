# typed: false
# frozen_string_literal: true

class AddMissingUniqueIndexesNotification < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      %w(user_notifications staff_notifications client_notifications admin_notifications).each do |table|
        unless index_exists?(table, :public_id, unique: true)
          remove_index(table, :public_id) if index_exists?(table, :public_id)
          add_index(table, :public_id, unique: true, algorithm: :concurrently)
        end
      end
    end
  end

  def down
  end
end
