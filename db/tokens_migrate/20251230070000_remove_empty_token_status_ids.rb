# frozen_string_literal: true

class RemoveEmptyTokenStatusIds < ActiveRecord::Migration[8.2]
  def up
    %w(user_token_statuses staff_token_statuses).each do |table|
      next unless table_exists?(table)

      safety_assured do
        execute <<~SQL.squish
          DELETE FROM #{table}
          WHERE id = ''
        SQL
      end
    end
  end

  def down
    # no-op: we don't want to reinsert empty IDs
  end
end
