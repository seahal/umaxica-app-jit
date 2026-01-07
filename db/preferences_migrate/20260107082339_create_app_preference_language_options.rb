# frozen_string_literal: true

class CreateAppPreferenceLanguageOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_language_options, id: :uuid do |t|
    end
  end
end
