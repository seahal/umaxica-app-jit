# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentFkSmallintTest < ActiveSupport::TestCase
  class FakeMigration
    include MigrationHelpers::DocumentFkSmallint

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

    def foreign_key_exists?(table_name, to_table:, column:)
      @existing_foreign_keys.fetch([table_name.to_s, to_table.to_s, column.to_s], false)
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

    def remove_column(*args)
      calls << [:remove_column, *args]
    end

    def rename_column(*args)
      calls << [:rename_column, *args]
    end

    def add_index(*args, **kwargs)
      calls << [:add_index, *args, kwargs]
    end

    def add_check_constraint(*args, **kwargs)
      calls << [:add_check_constraint, *args, kwargs]
    end

    def add_foreign_key(*args, **kwargs)
      calls << [:add_foreign_key, *args, kwargs]
    end

    def execute(sql)
      executed_sql << sql.squish
    end

    def quote(value)
      "'#{value}'"
    end
  end

  test "DocumentFkSmallint module exists" do
    assert_kind_of Module, MigrationHelpers::DocumentFkSmallint
  end

  test "DocumentFkSmallint includes DocumentReferenceSmallint" do
    assert_includes MigrationHelpers::DocumentFkSmallint, MigrationHelpers::DocumentReferenceSmallint
  end

  test "fk_in_condition returns FALSE for empty values" do
    migration = Class.new do
      include MigrationHelpers::DocumentFkSmallint

      define_method(:quote) do |value|
        "'#{value}'"
      end
    end.new

    result = migration.send(:fk_in_condition, "users", "org_id", [])

    assert_equal "FALSE", result
  end

  test "fk_in_condition returns IN clause for values" do
    migration = Class.new do
      include MigrationHelpers::DocumentFkSmallint

      define_method(:quote) do |value|
        "'#{value}'"
      end
    end.new

    result = migration.send(:fk_in_condition, "users", "org_id", ["NEYO", "none"])

    assert_includes result, "users.org_id IN ("
    assert_includes result, "'NEYO'"
    assert_includes result, "'none'"
  end

  test "convert_fk_column_to_smallint orchestrates foreign key conversion" do
    migration = FakeMigration.new(
      existing_columns: [:org_id],
      existing_indexes: ["index_users_on_org_id"],
      existing_foreign_keys: { %w(users organizations org_id) => true },
    )

    migration.convert_fk_column_to_smallint(
      table_name: :users,
      column_name: :org_id,
      parent_table: :organizations,
      sentinel_values: ["NEYO", "none"],
      index_name: "index_users_on_org_id",
      foreign_key_options: { validate: false },
    )

    assert_includes migration.calls, [:safety_assured]
    assert_includes migration.calls, [:add_column, :users, "org_id_small", :integer, { limit: 2 }]
    assert_includes migration.calls, [:change_column_default, :users, "org_id_small", { from: nil, to: 0 }]
    assert_includes migration.calls, [:remove_foreign_key, :users, { column: :org_id, to_table: :organizations }]
    assert_includes migration.calls, [:remove_index, :users, { name: "index_users_on_org_id" }]
    assert_includes migration.calls, %i(remove_column users org_id)
    assert_includes migration.calls, [:rename_column, :users, "org_id_small", :org_id]
    assert_includes migration.calls,
                    [:add_foreign_key, :users, :organizations, { column: :org_id, primary_key: :id, validate: false }]
  end

  test "fill_fk_small_column maps legacy ids and nulls to sentinel value" do
    migration = FakeMigration.new

    migration.send(:fill_fk_small_column, :users, :org_id, :organizations, ["NEYO", "none"], "org_id_small")

    assert_includes migration.executed_sql.first, "WHEN users.org_id IN ('NEYO', 'none') THEN 0"
    assert_includes migration.executed_sql.first, "FROM organizations_legacy_id_map AS mapping"
    assert_includes migration.executed_sql.last, "UPDATE users SET org_id_small = 0 WHERE org_id_small IS NULL"
  end
end
