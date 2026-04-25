# frozen_string_literal: true

class RemoveRedundantIndexFromUserAppPreferences < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:user_app_preferences)
    return if !column_exists?(:user_app_preferences, :user_id) || !index_exists?(:user_app_preferences, :user_id)

    remove_index(:user_app_preferences, :user_id)
  end
end
