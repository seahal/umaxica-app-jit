# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersCoverageTest < ActiveSupport::TestCase
  class ReferenceMigration
    include MigrationHelpers::DocumentReferenceSmallint

    attr_reader :calls, :executed_sql

    def initialize(existing_columns: [], existing_indexes: [], existing_tables: [])
      @calls = []
      @executed_sql = []
      @existing_columns = existing_columns.map(&:to_s)
      @existing_indexes = existing_indexes.map(&:to_s)
      @existing_tables = existing_tables.map(&:to_s)
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

    def foreign_key_exists?(*, **)
      false
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

    def add_primary_key_constraint(*args)
      calls << [:add_primary_key_constraint, *args]
    end

    def drop_primary_key_constraint(*args)
      calls << [:drop_primary_key_constraint, *args]
    end

    def add_check_constraint(*args, **kwargs)
      calls << [:add_check_constraint, *args, kwargs]
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
  end

  class FkMigration < ReferenceMigration
    include MigrationHelpers::DocumentFkSmallint

    def initialize(existing_columns: [], existing_indexes: [], existing_foreign_keys: {})
      super(existing_columns:, existing_indexes:)
      @existing_foreign_keys = existing_foreign_keys
    end

    def foreign_key_exists?(table_name, to_table:, column:)
      @existing_foreign_keys.fetch([table_name.to_s, to_table.to_s, column.to_s], false)
    end

    def add_foreign_key(*args, **kwargs)
      calls << [:add_foreign_key, *args, kwargs]
    end
  end

  class TreeMigration < ReferenceMigration
    include MigrationHelpers::DocumentTreeSmallint

    def initialize(existing_columns: [], existing_indexes: [], existing_foreign_keys: {})
      super(existing_columns:, existing_indexes:)
      @existing_foreign_keys = existing_foreign_keys
    end

    def foreign_key_exists?(table_name, column:)
      @existing_foreign_keys.fetch([table_name.to_s, column.to_s], false)
    end

    def add_foreign_key(*args, **kwargs)
      calls << [:add_foreign_key, *args, kwargs]
    end
  end

  test "document reference helpers build conversion sql and mapping tables" do
    migration = ReferenceMigration.new(existing_columns: [:id], existing_indexes: ["index_documents_on_lower_name"])

    migration.convert_string_id_pk_table(
      table_name: :documents,
      sentinel_id: "NEYO",
      lower_index: "index_documents_on_lower_name",
      check_constraint: "documents_id_check",
      child_foreign_keys: [{ table: :document_children, column: :document_id }],
    )

    assert_includes migration.calls, [:create_table, "documents_legacy_id_map"]
    assert migration.executed_sql.any? { |sql| sql.include?("UPDATE documents") }
    assert migration.executed_sql.any? { |sql| sql.include?("INSERT INTO documents_legacy_id_map") }
  end

  test "document fk helpers build foreign key migration sql" do
    migration = FkMigration.new(
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

    assert migration.executed_sql.any? { |sql| sql.include?("organizations_legacy_id_map") }
    assert_includes migration.calls,
                    [:add_foreign_key, :users, :organizations, { column: :org_id, primary_key: :id, validate: false }]
  end

  test "document tree helpers build id and parent remapping sql" do
    migration = TreeMigration.new(
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

    assert migration.executed_sql.any? { |sql| sql.include?("UPDATE categories") }
    assert_includes migration.calls,
                    [:add_foreign_key, :categories, :categories,
                     { column: "parent_id", primary_key: :id, validate: false },]
  end
end
