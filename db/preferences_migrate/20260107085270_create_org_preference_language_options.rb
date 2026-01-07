# frozen_string_literal: true

class CreateOrgPreferenceLanguageOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_language_options, id: :string do |t|
      t.timestamps
    end
  end
end
