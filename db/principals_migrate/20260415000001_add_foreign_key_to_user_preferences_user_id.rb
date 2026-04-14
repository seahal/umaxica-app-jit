# frozen_string_literal: true

class AddForeignKeyToUserPreferencesUserId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key(:user_preferences, :users, validate: false)
  end
end
