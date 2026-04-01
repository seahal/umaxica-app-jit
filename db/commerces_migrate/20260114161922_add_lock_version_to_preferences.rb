# frozen_string_literal: true

class AddLockVersionToPreferences < ActiveRecord::Migration[8.2]
  def change
    %i(app_preferences com_preferences org_preferences).each do |table_name|
      add_column(table_name, :lock_version, :integer, null: false, default: 0)
    end
  end
end
