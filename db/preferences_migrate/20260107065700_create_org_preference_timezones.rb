# frozen_string_literal: true

class CreateOrgPreferenceTimezones < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_timezones, id: :uuid do |t|
      t.references :preference, null: false, foreign_key: { to_table: :org_preferences }, type: :uuid

      t.timestamps
    end
  end
end
