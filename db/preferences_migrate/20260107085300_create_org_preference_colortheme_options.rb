# frozen_string_literal: true

class CreateOrgPreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_preference_colortheme_options, id: :uuid do |t|
    end
  end
end
