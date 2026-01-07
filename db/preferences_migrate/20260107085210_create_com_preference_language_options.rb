# frozen_string_literal: true

class CreateComPreferenceLanguageOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preference_language_options, id: :uuid do |t|
    end
  end
end
