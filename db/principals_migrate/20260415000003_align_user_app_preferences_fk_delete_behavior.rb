# frozen_string_literal: true

class AlignUserAppPreferencesFkDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:user_app_preferences)
    return unless table_exists?(:users)
    return unless column_exists?(:user_app_preferences, :user_id)

    # Remove existing FK without on_delete
    remove_foreign_key(:user_app_preferences, :users) if foreign_key_exists?(:user_app_preferences, :users)
    # Add FK with on_delete: :cascade to match model's dependent: :delete_all
    add_foreign_key(:user_app_preferences, :users, on_delete: :cascade, validate: false) unless foreign_key_exists?(:user_app_preferences, :users)
  end
end
