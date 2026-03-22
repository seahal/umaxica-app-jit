# frozen_string_literal: true

class AddTimestampsToAppPreferenceLanguageOptions < ActiveRecord::Migration[8.2]
  def change
    return if column_exists?(:app_preference_language_options, :created_at)

    add_timestamps(:app_preference_language_options, null: false, default: -> { "CURRENT_TIMESTAMP" })
    change_column_default(:app_preference_language_options, :created_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil)
    change_column_default(:app_preference_language_options, :updated_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil)
  end
end
