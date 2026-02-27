# frozen_string_literal: true

class RenameNoneToNeyoInTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    rename_id("user_token_statuses", from: "NONE", to: "NEYO")
    rename_id("staff_token_statuses", from: "NONE", to: "NEYO")

    update_fk("user_tokens", :user_token_status_id, from: "NONE", to: "NEYO")
    update_fk("staff_tokens", :staff_token_status_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")
  end

  def down
    rename_id("user_token_statuses", from: "NEYO", to: "NONE")
    rename_id("staff_token_statuses", from: "NEYO", to: "NONE")

    update_fk("user_tokens", :user_token_status_id, from: "NEYO", to: "NONE")
    update_fk("staff_tokens", :staff_token_status_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")
  end

  private

  def rename_id(table, from:, to:)
    return unless table_exists?(table)

    change_column_default_if_exists(table, :id, from: from, to: to)
  end

  def update_fk(table, column, from:, to:)
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
