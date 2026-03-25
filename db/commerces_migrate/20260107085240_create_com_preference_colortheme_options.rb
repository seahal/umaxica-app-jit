# frozen_string_literal: true

class CreateComPreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  def up
    create_table(:com_preference_colortheme_options, id: :string) do |t|
      t.timestamps
    end

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO com_preference_colortheme_options (id, created_at, updated_at)
        VALUES ('light', NOW(), NOW()), ('dark', NOW(), NOW()), ('system', NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    drop_table(:com_preference_colortheme_options)
  end
end
