# frozen_string_literal: true

class EnsureNeyoInTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    update_column_value(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    update_column_value(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")
  end

  def down
    update_column_value(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    update_column_value(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")
  end

  private

  def update_column_value(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET #{column} = '#{to}'
        WHERE #{column} = '#{from}'
      SQL
    end
  end

  def change_column_default_if_exists(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    change_column_default table, column, from: from, to: to
  end
end
