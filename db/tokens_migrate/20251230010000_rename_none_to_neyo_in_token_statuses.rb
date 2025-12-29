# frozen_string_literal: true

class RenameNoneToNeyoInTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    rename_id("user_token_statuses", from: "NONE", to: "NEYO")
    rename_id("staff_token_statuses", from: "NONE", to: "NEYO")

    update_fk("user_tokens", :user_token_status_id, from: "NONE", to: "NEYO")
    update_fk("staff_tokens", :staff_token_status_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NONE", to: "NEYO")

    delete_id("user_token_statuses", "NONE")
    delete_id("staff_token_statuses", "NONE")
  end

  def down
    rename_id("user_token_statuses", from: "NEYO", to: "NONE")
    rename_id("staff_token_statuses", from: "NEYO", to: "NONE")

    update_fk("user_tokens", :user_token_status_id, from: "NEYO", to: "NONE")
    update_fk("staff_tokens", :staff_token_status_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:user_tokens, :user_token_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_tokens, :staff_token_status_id, from: "NEYO", to: "NONE")

    delete_id("user_token_statuses", "NEYO")
    delete_id("staff_token_statuses", "NEYO")
  end

  private

  def rename_id(table, from:, to:)
    return unless table_exists?(table)

    has_timestamps = column_exists?(table, :created_at) && column_exists?(table, :updated_at)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (id#{has_timestamps ? ", created_at, updated_at" : ""})
        VALUES ('#{to}'#{has_timestamps ? ", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP" : ""})
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    change_column_default_if_exists(table, :id, from: from, to: to)
  end

  def insert_sql(table, id, has_timestamps)
    if has_timestamps
      "INSERT INTO #{table} (id, created_at, updated_at) VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"
    else
      "INSERT INTO #{table} (id) VALUES ('#{id}');"
    end
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

  def delete_id(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE id = '#{id}'
      SQL
    end
  end
end
