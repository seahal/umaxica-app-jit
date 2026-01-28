# frozen_string_literal: true

class FixTokenConsistency < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE UNIQUE INDEX IF NOT EXISTS index_user_token_statuses_on_lower_id ON user_token_statuses (lower(id))"
        execute "CREATE UNIQUE INDEX IF NOT EXISTS index_staff_token_statuses_on_lower_id ON staff_token_statuses (lower(id))"
      end
      dir.down do
        execute "DROP INDEX IF EXISTS index_user_token_statuses_on_lower_id"
        execute "DROP INDEX IF EXISTS index_staff_token_statuses_on_lower_id"
      end
    end
  end
end
