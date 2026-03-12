# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentTreeSmallintTest < ActiveSupport::TestCase
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
end
