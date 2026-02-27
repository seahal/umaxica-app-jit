# frozen_string_literal: true

class FixContactStatusForeignKeysRestrict < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      fix_fk(:app_contacts, :app_contact_statuses)
      fix_fk(:com_contacts, :com_contact_statuses)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_fk(table_name, status_table)
    return unless table_exists?(table_name)

    rows = connection.select_all(<<~SQL.squish)
      SELECT conname
      FROM pg_constraint
      WHERE conrelid = '#{table_name}'::regclass
        AND confrelid = '#{status_table}'::regclass
        AND contype = 'f'
    SQL

    rows.each do |row|
      execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{row["conname"]}"
    end

    add_foreign_key table_name, status_table, column: :status_id
  end
end
