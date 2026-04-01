# frozen_string_literal: true

class RemoveNothingPreferenceOptions < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        DELETE FROM app_preference_region_options WHERE id = 0
      SQL

      execute(<<~SQL.squish)
        DELETE FROM app_preference_colortheme_options WHERE id = 0
      SQL
    end
  end

  def down
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
end
