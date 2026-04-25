# frozen_string_literal: true

class SeedComPreferenceActivityEventNothingZero < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:com_preference_activity_events)

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO com_preference_activity_events (id)
        VALUES (0)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # Keep shared reference data in place once introduced.
  end
end
