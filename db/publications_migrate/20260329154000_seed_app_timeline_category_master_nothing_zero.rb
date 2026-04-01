# frozen_string_literal: true

class SeedAppTimelineCategoryMasterNothingZero < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:app_timeline_category_masters)

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO app_timeline_category_masters (id, parent_id)
        VALUES (0, 0)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # Keep shared reference data in place once introduced.
  end
end
