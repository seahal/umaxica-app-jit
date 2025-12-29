# frozen_string_literal: true

class EnsureNeyoInTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    %w(user_token_statuses staff_token_statuses).each do |table|
      insert_status(table, "NEYO")
      delete_status(table, "NONE")
    end

    update_column_value(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    update_column_value(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")
  end

  def down
    %w(user_token_statuses staff_token_statuses).each do |table|
      insert_status(table, "NONE")
      delete_status(table, "NEYO")
    end

    update_column_value(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    update_column_value(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")
  end

  private

  def insert_status(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (id)
        VALUES ('#{id}')
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def delete_status(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE id = '#{id}'
      SQL
    end
  end

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
