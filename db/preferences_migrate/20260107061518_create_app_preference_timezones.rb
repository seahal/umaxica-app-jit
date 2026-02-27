# frozen_string_literal: true

class CreateAppPreferenceTimezones < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_timezones do |t|
      t.references :preference, null: false, foreign_key: { to_table: :app_preferences }, type: :bigint

      t.timestamps
    end
  end
end
