# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentTreeSmallintTest < ActiveSupport::TestCase
  class FakeMigration
    include MigrationHelpers::DocumentTreeSmallint

    attr_reader :calls, :executed_sql

    def initialize(existing_columns: [], existing_indexes: [], existing_foreign_keys: {})
      @calls = []
      @executed_sql = []
      @existing_columns = existing_columns.map(&:to_s)
      @existing_indexes = existing_indexes.map(&:to_s)
      @existing_foreign_keys = existing_foreign_keys
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

    def foreign_key_exists?(table_name, column:)
      @existing_foreign_keys.fetch([table_name.to_s, column.to_s], false)
    end

    def remove_foreign_key(*args, **kwargs)
      calls << [:remove_foreign_key, *args, kwargs]
    end

    def index_exists?(_table_name, name:)
      @existing_indexes.include?(name.to_s)
    end

    def remove_index(*args, **kwargs)
      calls << [:remove_index, *args, kwargs]
    end

    def remove_check_constraint(*args)
      calls << [:remove_check_constraint, *args]
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

    def add_index(*args, **kwargs)
      calls << [:add_index, *args, kwargs]
    end

    def add_foreign_key(*args, **kwargs)
      calls << [:add_foreign_key, *args, kwargs]
    end

    def table_exists?(_table_name)
      false
    end

    def create_table(table_name)
      calls << [:create_table, table_name]
      table = Object.new
      table.define_singleton_method(:string) { |*_args, **_kwargs| nil }
      table.define_singleton_method(:integer) { |*_args, **_kwargs| nil }
      yield table
    end

    def execute(sql)
      executed_sql << sql.squish
    end

    def quote(value)
      "'#{value}'"
    end
  end

  test "DocumentTreeSmallint module exists" do
    assert_kind_of Module, MigrationHelpers::DocumentTreeSmallint
  end

  test "DocumentTreeSmallint includes ForeignKeyHelpers" do
    assert_includes MigrationHelpers::DocumentTreeSmallint, MigrationHelpers::ForeignKeyHelpers
  end

  test "DocumentTreeSmallint includes DocumentReferenceSmallint" do
    assert_includes MigrationHelpers::DocumentTreeSmallint, MigrationHelpers::DocumentReferenceSmallint
  end

  test "DEFAULT_PARENT_COLUMN is parent_id" do
    assert_equal "parent_id", MigrationHelpers::DocumentTreeSmallint::DEFAULT_PARENT_COLUMN
  end

  test "tree_sentinel_case returns case statement with sentinel" do
    migration = Class.new do
      include MigrationHelpers::DocumentTreeSmallint

      define_method(:quote) do |value|
        "'#{value}'"
      end
    end.new

    result = migration.send(:tree_sentinel_case, "categories", ["NEYO"])

    assert_includes result, "CASE WHEN"
    assert_includes result, "categories.id IN"
  end

  test "tree_sentinel_case returns row_number without sentinel" do
    migration = Class.new do
      include MigrationHelpers::DocumentTreeSmallint
    end.new

    result = migration.send(:tree_sentinel_case, "categories", [])

    assert_equal "row_number() OVER (ORDER BY id)", result
  end

  test "tree_in_condition returns FALSE for empty values" do
    migration = Class.new do
      include MigrationHelpers::DocumentTreeSmallint
    end.new

    result = migration.send(:tree_in_condition, "categories", "id", [])

    assert_equal "FALSE", result
  end

  test "tree_in_condition returns IN clause for values" do
    migration = Class.new do
      include MigrationHelpers::DocumentTreeSmallint

      define_method(:quote) do |value|
        "'#{value}'"
      end
    end.new

    result = migration.send(:tree_in_condition, "categories", "id", ["NEYO", "none"])

    assert_includes result, "categories.id IN ("
    assert_includes result, "'NEYO'"
    assert_includes result, "'none'"
  end

  test "convert_tree_reference_table orchestrates tree id and parent conversion" do
    migration = FakeMigration.new(
      existing_columns: [:id, :parent_id],
      existing_indexes: ["index_categories_on_lower_name", "index_categories_on_parent_id"],
      existing_foreign_keys: { ["categories", "parent_id"] => true },
    )

    migration.convert_tree_reference_table(
      table_name: :categories,
      id_sentinel_values: ["NEYO"],
      parent_sentinel_values: ["NEYO", "none"],
      lower_index: "index_categories_on_lower_name",
      check_constraint: "categories_parent_check",
      parent_index: "index_categories_on_parent_id",
    )

    assert_includes migration.calls, [:safety_assured]
    assert_includes migration.calls, [:add_column, :categories, :id_small, :integer, { limit: 2 }]
    assert_includes migration.calls, [:add_column, :categories, :parent_id_small, :integer, { limit: 2 }]
    assert_includes migration.calls, [:remove_foreign_key, :categories, { column: "parent_id" }]
    assert_includes migration.calls, [:remove_index, :categories, { name: "index_categories_on_lower_name" }]
    assert_includes migration.calls, [:remove_index, :categories, { name: "index_categories_on_parent_id" }]
    assert_includes migration.calls, %i(rename_column categories id_small id)
    assert_includes migration.calls, [:rename_column, :categories, :parent_id_small, "parent_id"]
    assert_includes migration.calls,
                    [:add_foreign_key, :categories, :categories,
                     { column: "parent_id", primary_key: :id, validate: false },]
    assert migration.executed_sql.any? { |sql| sql.include?("UPDATE categories") }
  end

  test "fill_tree_smallint_ids writes update statement" do
    migration = FakeMigration.new

    migration.send(:fill_tree_smallint_ids, :categories, ["NEYO"])

    sql = migration.executed_sql.first

    assert_includes sql, "WITH mapping AS"
    assert_includes sql, "UPDATE categories"
    assert_includes sql, "SET id_small = mapping.new_id"
  end

  test "fill_parent_id_small maps sentinels and nulls" do
    migration = FakeMigration.new

    migration.send(:fill_parent_id_small, :categories, :parent_id, ["NEYO", "none"])

    assert_includes migration.executed_sql.first, "WHEN categories.parent_id IN ('NEYO', 'none') THEN 0"
    assert_includes migration.executed_sql.first, "FROM categories_legacy_id_map AS mapping"
    assert_includes migration.executed_sql.last,
                    "UPDATE categories SET parent_id_small = 0 WHERE parent_id_small IS NULL"
  end
end
