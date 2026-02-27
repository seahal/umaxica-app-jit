# frozen_string_literal: true

class SetEmptyDefaultForTokenStatusIds < ActiveRecord::Migration[8.2]
  def up
    %w(user_token_statuses staff_token_statuses).each do |table|
      next unless table_exists?(table)

      change_column_default table, :id, from: "NEYO", to: ""
    end
  end

  def down
    %w(user_token_statuses staff_token_statuses).each do |table|
      next unless table_exists?(table)

      change_column_default table, :id, from: "", to: "NEYO"
    end
  end

  private
end
