# frozen_string_literal: true

class FixOccurrenceFks < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      prefixes = %w(area domain email ip staff telephone user zip)

      prefixes.each do |prefix|
        table_name = "#{prefix}_occurrences"
        status_table = "#{prefix}_occurrence_statuses"

        next unless table_exists?(table_name)

        execute "TRUNCATE TABLE #{table_name} CASCADE"

        if column_exists?(table_name, :status_id)
          execute "ALTER TABLE #{table_name} ALTER COLUMN status_id DROP DEFAULT"
          execute "ALTER TABLE #{table_name} ALTER COLUMN status_id TYPE bigint USING 0"
          execute "ALTER TABLE #{table_name} ALTER COLUMN status_id SET DEFAULT 0"
          execute "ALTER TABLE #{table_name} ALTER COLUMN status_id SET NOT NULL"

          add_fk_sql(table_name, status_table, :status_id)
        end

        if column_exists?(table_name, :public_id)
          execute "DELETE FROM #{table_name} WHERE public_id IS NULL"
          execute "ALTER TABLE #{table_name} ALTER COLUMN public_id SET NOT NULL"
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def add_fk_sql(from_table, to_table, column)
    fk_name = "fk_#{from_table}_on_#{column}"
    result = connection.select_value("SELECT 1 FROM pg_constraint WHERE conname = '#{fk_name}'")
    unless result
      execute "ALTER TABLE #{from_table} ADD CONSTRAINT #{fk_name} FOREIGN KEY (#{column}) REFERENCES #{to_table} (id)"
    end
  rescue => e
    Rails.logger.debug { "Error adding FK #{fk_name}: #{e.message}" }
  end
end
