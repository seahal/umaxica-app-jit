# frozen_string_literal: true

class EnsureNothingPreferenceOptions < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO app_preference_region_options (id)
        VALUES (0)
        ON CONFLICT (id) DO NOTHING
      SQL

      execute(<<~SQL.squish)
        INSERT INTO app_preference_colortheme_options (id)
        VALUES (0)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # no-op: keep seeded reference data
  end
end
