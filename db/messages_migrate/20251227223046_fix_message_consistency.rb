# frozen_string_literal: true

class FixMessageConsistency < ActiveRecord::Migration[8.2]
  def change
    add_index :user_messages, :user_id, if_not_exists: true
    add_index :staff_messages, :staff_id, if_not_exists: true
  end
end
