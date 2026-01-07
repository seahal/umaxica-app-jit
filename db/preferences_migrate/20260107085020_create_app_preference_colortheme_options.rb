# frozen_string_literal: true

class CreateAppPreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :app_preference_colortheme_options, id: :uuid do |t|
    end
  end
end
