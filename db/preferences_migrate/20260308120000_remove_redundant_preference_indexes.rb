# frozen_string_literal: true

class RemoveRedundantPreferenceIndexes < ActiveRecord::Migration[8.2]
  def change
    remove_index :staff_org_preferences, :staff_id
    remove_index :user_app_preferences, :user_id
  end
end
