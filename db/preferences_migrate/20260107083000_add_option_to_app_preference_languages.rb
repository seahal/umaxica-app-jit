# frozen_string_literal: true

class AddOptionToAppPreferenceLanguages < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :app_preference_languages, :option_id, :uuid unless column_exists?(:app_preference_languages, :option_id)
    add_index :app_preference_languages, :option_id, name: "index_app_preference_languages_on_option_id", algorithm: :concurrently unless index_exists?(:app_preference_languages, :option_id, name: "index_app_preference_languages_on_option_id")
    add_foreign_key :app_preference_languages, :app_preference_language_options, column: :option_id, primary_key: :id, validate: false unless foreign_key_exists?(:app_preference_languages, :app_preference_language_options, column: :option_id)
  end
end
