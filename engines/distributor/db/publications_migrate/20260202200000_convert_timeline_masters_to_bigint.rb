# typed: false
# frozen_string_literal: true

class ConvertTimelineMastersToBigint < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  # List of timeline master tables and their parent FKs
  TIMELINE_MASTER_TABLES = %w(
    org_timeline_tag_masters
    org_timeline_statuses
    org_timeline_category_masters
    com_timeline_tag_masters
    com_timeline_statuses
    com_timeline_category_masters
    app_timeline_tag_masters
    app_timeline_statuses
    app_timeline_category_masters
  ).freeze

  # Tables that reference the masters
  REFERENCING_TABLES = {
    "org_timeline_tag_masters" => [{ table: "org_timeline_tags", column: "org_timeline_tag_master_id" }],
    "org_timeline_statuses" => [{ table: "org_timelines", column: "status_id" }],
    "org_timeline_category_masters" => [{ table: "org_timeline_categories",
                                          column: "org_timeline_category_master_id", }],
    "com_timeline_tag_masters" => [{ table: "com_timeline_tags", column: "com_timeline_tag_master_id" }],
    "com_timeline_statuses" => [{ table: "com_timelines", column: "status_id" }],
    "com_timeline_category_masters" => [{ table: "com_timeline_categories",
                                          column: "com_timeline_category_master_id", }],
    "app_timeline_tag_masters" => [{ table: "app_timeline_tags", column: "app_timeline_tag_master_id" }],
    "app_timeline_statuses" => [{ table: "app_timelines", column: "status_id" }],
    "app_timeline_category_masters" => [{ table: "app_timeline_categories",
                                          column: "app_timeline_category_master_id", }],
  }.freeze

  def up
    safety_assured do
      enable_extension('citext') unless extension_enabled?('citext')

      TIMELINE_MASTER_TABLES.each do |master_table|
        convert_master_to_bigint(master_table)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def convert_master_to_bigint(master_table)
    return unless table_exists?(master_table)

    Rails.logger.debug { "Converting #{master_table} to bigint..." }

    # 1. Find and truncate all referencing tables
    refs = REFERENCING_TABLES[master_table] || []
    refs.each do |ref|
      if table_exists?(ref[:table])
        execute("TRUNCATE TABLE #{ref[:table]} CASCADE")
      end
    end

    # 2. Truncate the master table
    execute("TRUNCATE TABLE #{master_table} CASCADE")

    # 3. Drop FKs from referencing tables
    refs.each do |ref|
      drop_fks_from_table(ref[:table], master_table) if table_exists?(ref[:table])
    end

    # 4. Drop self-referencing FK (parent_id)
    drop_fks_from_table(master_table, master_table)

    # 5. Convert PK from smallint to bigint
    # Drop constraints first
    begin
      execute("ALTER TABLE #{master_table} DROP CONSTRAINT IF EXISTS #{master_table}_id_non_negative")
    rescue => e
      Rails.logger.debug { "Warning: #{e.message}" }
    end

    # Recreate table with bigint id
    # Get columns
    cols_result = connection.select_all(<<~SQL.squish)
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = '#{master_table}'
      AND column_name != 'id'
      ORDER BY ordinal_position
    SQL

    drop_table(master_table.to_sym, force: :cascade)

    create_table(master_table.to_sym) do |t|
      cols_result.each do |col|
        case col['column_name']
        when 'code'
          t.citext(:code, null: false)
        when 'parent_id'
          t.bigint(:parent_id)
        end
      end
    end

    # Add code unique index if has code column
    if cols_result.any? { |c| c['column_name'] == 'code' }
      add_index(master_table.to_sym, :code, unique: true)
    end

    # Add parent_id index and FK if has parent_id column
    if cols_result.any? { |c| c['column_name'] == 'parent_id' }
      add_index(master_table.to_sym, :parent_id)
      execute("ALTER TABLE #{master_table} ADD CONSTRAINT fk_#{master_table}_parent FOREIGN KEY (parent_id) REFERENCES #{master_table} (id)")
    end

    # 6. Convert FK columns in referencing tables to bigint
    refs.each do |ref|
      next unless table_exists?(ref[:table]) && column_exists?(ref[:table], ref[:column])

      execute("ALTER TABLE #{ref[:table]} ALTER COLUMN #{ref[:column]} DROP DEFAULT")
      execute("ALTER TABLE #{ref[:table]} ALTER COLUMN #{ref[:column]} TYPE bigint USING 0")
      execute("ALTER TABLE #{ref[:table]} ALTER COLUMN #{ref[:column]} SET DEFAULT 0")
      execute("ALTER TABLE #{ref[:table]} ALTER COLUMN #{ref[:column]} SET NOT NULL")

      # Add FK back
      fk_name = "fk_#{ref[:table]}_on_#{ref[:column]}"
      execute("ALTER TABLE #{ref[:table]} ADD CONSTRAINT #{fk_name} FOREIGN KEY (#{ref[:column]}) REFERENCES #{master_table} (id)")
    end

    Rails.logger.debug { "Converted #{master_table} to bigint successfully." }
  rescue => e
    Rails.logger.debug { "Error converting #{master_table}: #{e.message}" }
  end

  def drop_fks_from_table(from_table, to_table)
    return unless table_exists?(from_table) && table_exists?(to_table)

    fk_rows = connection.select_all(<<~SQL.squish)
      SELECT conname FROM pg_constraint#{" "}
      WHERE conrelid = '#{from_table}'::regclass#{" "}
        AND confrelid = '#{to_table}'::regclass
    SQL

    fk_rows.each do |row|
      execute("ALTER TABLE #{from_table} DROP CONSTRAINT #{row["conname"]}")
    end
  rescue => e
    Rails.logger.debug { "Warning dropping FK: #{e.message}" }
  end
end
