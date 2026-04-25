# frozen_string_literal: true

class CreateOrgPreferenceRegions < ActiveRecord::Migration[8.2]
  def change
    create_table(:org_preference_regions) do |t|
      t.references(:preference, null: false, foreign_key: { to_table: :org_preferences }, type: :bigint)

      t.timestamps
    end
  end
end
