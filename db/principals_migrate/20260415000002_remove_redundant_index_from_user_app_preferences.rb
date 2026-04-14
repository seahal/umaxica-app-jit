# frozen_string_literal: true

class RemoveRedundantIndexFromUserAppPreferences < ActiveRecord::Migration[8.2]
  def change
    remove_index(:user_app_preferences, :user_id)
  end
end
