# frozen_string_literal: true

class FixMessageCascade < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # 1. client_messages.user_message_id -> ON DELETE CASCADE
      replace_fk_with_cascade(:client_messages, :user_messages, :user_message_id)

      # 2. admin_messages.staff_message_id -> ON DELETE CASCADE
      replace_fk_with_cascade(:admin_messages, :staff_messages, :staff_message_id)

      # 3. Ensure public_id NOT NULL for all message tables
      %w(user_messages staff_messages client_messages admin_messages).each do |table|
        if table_exists?(table) && column_exists?(table, :public_id)
          execute "UPDATE #{table} SET public_id = gen_random_uuid() WHERE public_id IS NULL"
          execute "ALTER TABLE #{table} ALTER COLUMN public_id SET NOT NULL"
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def replace_fk_with_cascade(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    # Find and drop existing FK
    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint#{" "}
      WHERE conrelid = '#{from_table}'::regclass#{" "}
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute "ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}"
    end

    # Add new FK with ON DELETE CASCADE
    fk_name = "fk_#{from_table}_on_#{column}_cascade"
    execute <<~SQL.squish
      ALTER TABLE #{from_table}#{" "}
      ADD CONSTRAINT #{fk_name}#{" "}
      FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)#{" "}
      ON DELETE CASCADE
    SQL
  end
end
