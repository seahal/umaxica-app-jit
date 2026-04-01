# frozen_string_literal: true

class FixContactFks < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      %w(app com org).each do |prefix|
        table_name = "#{prefix}_contacts"
        status_table = "#{prefix}_contact_statuses"

        next unless table_exists?(table_name)

        # Remove old FK
        # check if exists
        # Rails usually names it fk_rails_...
        # We try to remove by name if we can match it, or just ignore.
        # But we need to add new one.
        # If we just add new one, we might redundant.
        # We can query conname.

        rows = connection.select_all("SELECT conname FROM pg_constraint WHERE conrelid = '#{table_name}'::regclass AND confrelid = '#{status_table}'::regclass")
        rows.each do |row|
          execute("ALTER TABLE #{table_name} DROP CONSTRAINT #{row["conname"]}")
        end

        # Add new one with ON DELETE SET NULL
        execute("ALTER TABLE #{table_name} ADD CONSTRAINT fk_#{table_name}_status_nullify FOREIGN KEY (status_id) REFERENCES #{status_table} (id) ON DELETE SET NULL")
      end

      # Fix ComContact email index
      fix_unique_index(:com_contact_emails, :com_contact_id)
      fix_unique_index(:com_contact_telephones, :com_contact_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_unique_index(table, col)
    return unless table_exists?(table)

    # Remove existing index on col if any
    # We can try remove_index (helper) as it is usually safe enough if disable_ddl_transaction! is on?
    # Or just SQL.
    # SQL is safer to avoid StrongMigrations "add index concurrently" requirement.

    # Index name?
    # We can just drop index by name if we guess it.
    # index_com_contact_emails_on_com_contact_id
    index_name = "index_#{table}_on_#{col}"
    execute("DROP INDEX IF EXISTS #{index_name}")

    # Create unique index
    execute("CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS #{index_name} ON #{table} (#{col})")
  end
end
