# frozen_string_literal: true

class CreateAppPreferenceTimezoneOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_timezone_options, id: :string do |t|
    end
  end
end
