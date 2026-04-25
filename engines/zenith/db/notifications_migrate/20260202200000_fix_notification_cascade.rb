# typed: false
# frozen_string_literal: true

class FixNotificationCascade < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # 1. client_notifications.user_notification_id -> ON DELETE CASCADE
      replace_fk_with_cascade(:client_notifications, :user_notifications, :user_notification_id)

      # 2. admin_notifications.staff_notification_id -> ON DELETE CASCADE
      replace_fk_with_cascade(:admin_notifications, :staff_notifications, :staff_notification_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def replace_fk_with_cascade(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)

    # Find and drop existing FK
    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint#{" "}
      WHERE conrelid = '#{from_table}'::regclass#{" "}
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute("ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}")
    end

    # Add new FK with ON DELETE CASCADE
    fk_name = "fk_#{from_table}_on_#{column}_cascade"
    execute(<<~SQL.squish)
      ALTER TABLE #{from_table}#{" "}
      ADD CONSTRAINT #{fk_name}#{" "}
      FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)#{" "}
      ON DELETE CASCADE
    SQL
  end
end
