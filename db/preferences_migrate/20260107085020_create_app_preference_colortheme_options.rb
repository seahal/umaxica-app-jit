# frozen_string_literal: true

class CreateAppPreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  def up
    create_table(:app_preference_colortheme_options, id: :string) do |t|
      t.timestamps
    end

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO app_preference_colortheme_options (id, created_at, updated_at)
        VALUES ('light', NOW(), NOW()), ('dark', NOW(), NOW()), ('system', NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    drop_table(:app_preference_colortheme_options)
  end
end
