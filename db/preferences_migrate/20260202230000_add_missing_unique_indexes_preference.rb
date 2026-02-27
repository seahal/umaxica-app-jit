# frozen_string_literal: true

class AddMissingUniqueIndexesPreference < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      %w(org_preferences com_preferences app_preferences).each do |table|
        unless index_exists?(table, :public_id, unique: true)
          remove_index table, :public_id if index_exists?(table, :public_id)
          add_index table, :public_id, unique: true, algorithm: :concurrently
        end
      end
    end
  end

  def down
  end
end
