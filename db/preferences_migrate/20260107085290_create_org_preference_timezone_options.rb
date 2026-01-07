# frozen_string_literal: true

class CreateOrgPreferenceTimezoneOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_timezone_options, id: :uuid do |t|
    end
  end
end
