# frozen_string_literal: true

class CreateComPreferenceRegionOptions < ActiveRecord::Migration[8.2]
  def up
    create_table :com_preference_region_options, id: :string do |t|
      t.timestamps
    end

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO com_preference_region_options (id, created_at, updated_at)
        VALUES ('US', NOW(), NOW()), ('JP', NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    drop_table :com_preference_region_options
  end
end
