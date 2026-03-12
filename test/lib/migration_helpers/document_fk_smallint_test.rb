# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentFkSmallintTest < ActiveSupport::TestCase
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
end
