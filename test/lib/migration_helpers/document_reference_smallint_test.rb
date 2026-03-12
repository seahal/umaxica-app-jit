# typed: false
# frozen_string_literal: true

require "test_helper"

class MigrationHelpersDocumentReferenceSmallintTest < ActiveSupport::TestCase
  test "ForeignKeyHelpers module exists" do
    assert_kind_of Module, MigrationHelpers::ForeignKeyHelpers
  end

  test "DocumentReferenceSmallint module includes ForeignKeyHelpers" do
    assert_includes MigrationHelpers::DocumentReferenceSmallint, MigrationHelpers::ForeignKeyHelpers
  end

  test "DEFAULT_PARENT_COLUMN is parent_id" do
    assert_equal "parent_id", MigrationHelpers::DocumentTreeSmallint::DEFAULT_PARENT_COLUMN
  end
end
