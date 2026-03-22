# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentReferenceSmallintTest < ActiveSupport::TestCase
  class FakeMigration
    include MigrationHelpers::DocumentReferenceSmallint

    attr_reader :calls, :executed_sql

    def initialize(existing_columns: [], existing_indexes: [], existing_foreign_keys: {}, existing_tables: [])
      @calls = []
      @executed_sql = []
      @existing_columns = normalize_list(existing_columns)
      @existing_indexes = normalize_list(existing_indexes)
      @existing_foreign_keys = existing_foreign_keys
      @existing_tables = normalize_list(existing_tables)
    end

    def safety_assured
      calls << [:safety_assured]
      yield
    end

    def column_exists?(_table_name, column_name)
      @existing_columns.include?(column_name.to_s)
    end

    def add_column(*args)
      calls << [:add_column, *args]
    end

    def change_column_default(*args, **kwargs)
      calls << [:change_column_default, *args, kwargs]
    end

    def change_column_null(*args)
      calls << [:change_column_null, *args]
    end

    def index_exists?(_table_name, name:)
      @existing_indexes.include?(name.to_s)
    end

    def remove_index(*args, **kwargs)
      calls << [:remove_index, *args, kwargs]
    end

    def drop_primary_key_constraint(*args)
      calls << [:drop_primary_key_constraint, *args]
    end

    def remove_column(*args)
      calls << [:remove_column, *args]
    end

    def rename_column(*args)
      calls << [:rename_column, *args]
    end

    def add_primary_key_constraint(*args)
      calls << [:add_primary_key_constraint, *args]
    end

    def add_check_constraint(*args, **kwargs)
      calls << [:add_check_constraint, *args, kwargs]
    end

    def foreign_key_exists?(table_name, to_table: nil, column:)
      @existing_foreign_keys.fetch([table_name.to_s, to_table&.to_s, column.to_s], false)
    end

    def remove_foreign_key(*args, **kwargs)
      calls << [:remove_foreign_key, *args, kwargs]
    end

    def execute(sql)
      executed_sql << sql.squish
    end

    def quote(value)
      "'#{value}'"
    end

    def table_exists?(table_name)
      @existing_tables.include?(table_name.to_s)
    end

    def create_table(table_name)
      calls << [:create_table, table_name]
      table = Object.new
      table.define_singleton_method(:string) { |*_args, **_kwargs| nil }
      table.define_singleton_method(:integer) { |*_args, **_kwargs| nil }
      yield table
    end

    def add_index(*args, **kwargs)
      calls << [:add_index, *args, kwargs]
    end

    def drop_table(*args)
      calls << [:drop_table, *args]
    end

    private

    def normalize_list(values)
      values.map(&:to_s)
    end
  end

  test "ForeignKeyHelpers module exists" do
    assert_kind_of Module, MigrationHelpers::ForeignKeyHelpers
  end

  test "DocumentReferenceSmallint module includes ForeignKeyHelpers" do
    assert_includes MigrationHelpers::DocumentReferenceSmallint, MigrationHelpers::ForeignKeyHelpers
  end

  test "DEFAULT_PARENT_COLUMN is parent_id" do
    assert_equal "parent_id", MigrationHelpers::DocumentTreeSmallint::DEFAULT_PARENT_COLUMN
  end

  test "drop_child_foreign_keys removes matching foreign keys and skips incomplete definitions" do
    migration = FakeMigration.new(
      existing_foreign_keys: {
        %w(children parents parent_id) => true,
        ["children", nil, "legacy_id"] => true,
      },
    )

    migration.send(
      :drop_child_foreign_keys,
      [
        { table: "children", column: "parent_id", to_table: "parents" },
        { table: "children", column: "legacy_id" },
        { table: nil, column: "ignored_id", to_table: "ignored" },
      ],
    )

    assert_includes migration.calls, [:remove_foreign_key, "children", { column: "parent_id", to_table: "parents" }]
    assert_includes migration.calls, [:remove_foreign_key, "children", { column: "legacy_id" }]
  end

  test "convert_string_id_pk_table orchestrates schema changes" do
    migration = FakeMigration.new(existing_columns: [:id], existing_indexes: ["index_documents_on_lower_name"])

    migration.convert_string_id_pk_table(
      table_name: :documents,
      sentinel_id: "NEYO",
      lower_index: "index_documents_on_lower_name",
      check_constraint: "documents_id_check",
      child_foreign_keys: [{ table: :document_children, column: :document_id }],
    )

    assert_includes migration.calls, [:safety_assured]
    assert_includes migration.calls, [:add_column, :documents, :id_small, :integer, { limit: 2 }]
    assert_includes migration.calls, [:change_column_default, :documents, :id_small, { from: nil, to: 0 }]
    assert_includes migration.calls, [:change_column_null, :documents, :id_small, false]
    assert_includes migration.calls, [:remove_index, :documents, { name: "index_documents_on_lower_name" }]
    assert_includes migration.calls, [:drop_primary_key_constraint, :documents]
    assert_includes migration.calls, %i(remove_column documents id)
    assert_includes migration.calls, %i(rename_column documents id_small id)
    assert_includes migration.calls, [:add_primary_key_constraint, :documents]
    assert migration.executed_sql.any? { |sql| sql.include?("UPDATE documents") }
    assert migration.executed_sql.any? { |sql| sql.include?("INSERT INTO documents_legacy_id_map") }
  end

  test "fill_smallint_ids issues update sql with sentinel mapping" do
    migration = FakeMigration.new

    migration.send(:fill_smallint_ids, :documents, "NEYO")

    sql = migration.executed_sql.first

    assert_includes sql, "CASE WHEN id = 'NEYO' THEN 0 ELSE row_number() OVER (ORDER BY id) END AS new_id"
    assert_includes sql, "UPDATE documents"
    assert_includes sql, "SET id_small = mapping.new_id"
  end

  test "store_legacy_mapping creates mapping table when absent" do
    migration = FakeMigration.new

    migration.send(:store_legacy_mapping, :documents)

    assert_includes migration.calls, [:create_table, "documents_legacy_id_map"]
    assert_includes migration.calls,
                    [:add_index, "documents_legacy_id_map", :legacy_id,
                     { name: "documents_legacy_id_map_legacy_id_idx", unique: true },]
    assert_includes migration.executed_sql.last,
                    "INSERT INTO documents_legacy_id_map (legacy_id, new_id) SELECT id, id_small FROM documents"
  end

  test "store_legacy_mapping truncates mapping table when present" do
    migration = FakeMigration.new(existing_tables: ["documents_legacy_id_map"])

    migration.send(:store_legacy_mapping, :documents)

    assert_includes migration.executed_sql.first, "TRUNCATE documents_legacy_id_map"
  end

  test "legacy_mapping_table_name returns derived table name" do
    migration = FakeMigration.new

    assert_equal "documents_legacy_id_map", migration.send(:legacy_mapping_table_name, :documents)
  end

  test "remove_legacy_mapping drops mapping table when present" do
    migration = FakeMigration.new(existing_tables: ["documents_legacy_id_map"])

    migration.send(:remove_legacy_mapping, :documents)

    assert_includes migration.calls, [:drop_table, "documents_legacy_id_map"]
  end
end
