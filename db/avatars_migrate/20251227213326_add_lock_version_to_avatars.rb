# frozen_string_literal: true

class AddLockVersionToAvatars < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_column :avatars, :lock_version, :integer, default: 0, null: false
    end
  end
end
