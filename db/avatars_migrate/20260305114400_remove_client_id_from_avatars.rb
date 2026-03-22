# frozen_string_literal: true

class RemoveClientIdFromAvatars < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column(:avatars, :client_id, :bigint) if column_exists?(:avatars, :client_id)
    end
  end
end
