# frozen_string_literal: true

class AlignUserAppPreferencesFkDeleteBehavior < ActiveRecord::Migration[8.2]
  def change
    # Remove existing FK without on_delete
    remove_foreign_key(:user_app_preferences, :users)
    # Add FK with on_delete: :cascade to match model's dependent: :delete_all
    add_foreign_key(:user_app_preferences, :users, on_delete: :cascade, validate: false)
  end
end
