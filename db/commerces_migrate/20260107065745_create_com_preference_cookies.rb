# frozen_string_literal: true

class CreateComPreferenceCookies < ActiveRecord::Migration[8.2]
  def change
    create_table(:com_preference_cookies) do |t|
      t.references(:preference, null: false, foreign_key: { to_table: :com_preferences }, type: :bigint)

      t.timestamps
    end
  end
end
