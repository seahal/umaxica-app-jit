# frozen_string_literal: true

class AddDeletableAtToAppPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(:app_preferences, :deletable_at, :datetime, null: false, default: -> { "'infinity'" })
    end
    add_index(:app_preferences, :deletable_at, algorithm: :concurrently)
  end

  def down
    remove_index(:app_preferences, :deletable_at, algorithm: :concurrently)
    remove_column(:app_preferences, :deletable_at)
  end
end
