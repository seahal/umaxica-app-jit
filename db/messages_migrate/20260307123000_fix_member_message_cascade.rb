# frozen_string_literal: true

class FixMemberMessageCascade < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      replace_fk_with_cascade(:member_messages, :user_messages, :user_message_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def replace_fk_with_cascade(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table) && column_exists?(from_table, column)

    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint
      WHERE conrelid = '#{from_table}'::regclass
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute "ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}"
    end

    execute <<~SQL.squish
      ALTER TABLE #{from_table}
      ADD CONSTRAINT fk_#{from_table}_on_#{column}_cascade
      FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)
      ON DELETE CASCADE
    SQL
  end
end
