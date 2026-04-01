# frozen_string_literal: true

class RemoveLockVersionFromPreferences < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column(:app_preferences, :lock_version, :integer)
      remove_column(:com_preferences, :lock_version, :integer)
      remove_column(:org_preferences, :lock_version, :integer)
    end
  end
end
