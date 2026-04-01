# frozen_string_literal: true

class SeedAppPreferenceLanguageOptionNothingZero < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:app_preference_language_options)

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO app_preference_language_options (id)
        VALUES (0)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # Keep shared reference data in place once introduced.
  end
end
