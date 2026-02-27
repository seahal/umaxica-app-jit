# frozen_string_literal: true

class FixTokenPks < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      enable_extension 'citext' unless extension_enabled?('citext')

      fix_token_domain(:staff)
      fix_token_domain(:user)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_token_domain(prefix)
    tokens_table = "#{prefix}_tokens"
    kinds_table = "#{prefix}_token_kinds"
    statuses_table = "#{prefix}_token_statuses"

    return unless table_exists?(tokens_table)

    execute "TRUNCATE TABLE #{tokens_table} CASCADE"

    col_kind = "#{prefix}_token_kind_id"
    col_status = "#{prefix}_token_status_id"

    if column_exists?(tokens_table, col_kind)
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_kind} DROP DEFAULT"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_kind} TYPE bigint USING #{col_kind}::bigint"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_kind} SET DEFAULT 0"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_kind} SET NOT NULL"
    end

    if column_exists?(tokens_table, col_status)
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_status} DROP DEFAULT"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_status} TYPE bigint USING #{col_status}::bigint"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_status} SET DEFAULT 0"
      execute "ALTER TABLE #{tokens_table} ALTER COLUMN #{col_status} SET NOT NULL"
    end

    recreate_reference_table(kinds_table)
    recreate_reference_table(statuses_table)

    add_fk_sql(tokens_table, kinds_table, col_kind)
    add_fk_sql(tokens_table, statuses_table, col_status)

  end

  def recreate_reference_table(table_name)
    return unless table_exists?(table_name)

    drop_table table_name, force: :cascade
    create_table table_name do |t|
      t.citext :code, null: false
      t.index :code, unique: true
    end
  end

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
