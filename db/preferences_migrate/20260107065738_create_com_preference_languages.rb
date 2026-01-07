# frozen_string_literal: true

class CreateComPreferenceLanguages < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preference_languages, id: :uuid do |t|
      t.references :preference, null: false, foreign_key: { to_table: :com_preferences }, type: :uuid

      t.timestamps
    end
  end
end
