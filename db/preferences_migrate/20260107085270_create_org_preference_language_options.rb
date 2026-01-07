# frozen_string_literal: true

class CreateOrgPreferenceLanguageOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_language_options, id: :uuid do |t|
    end
  end
end
