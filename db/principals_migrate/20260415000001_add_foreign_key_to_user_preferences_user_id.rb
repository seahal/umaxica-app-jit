# frozen_string_literal: true

class AddForeignKeyToUserPreferencesUserId < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:user_preferences)
    return unless table_exists?(:users)
    return unless column_exists?(:user_preferences, :user_id)
    return if foreign_key_exists?(:user_preferences, :users)

    add_foreign_key(:user_preferences, :users, validate: false)
  end
end
