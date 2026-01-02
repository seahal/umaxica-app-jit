# == Schema Information
#
# Table name: app_document_category_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("NEYO"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_app_document_category_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

require "test_helper"

class AppDocumentCategoryMasterTest < ActiveSupport::TestCase
  test "validates id presence and uniqueness" do
    master = AppDocumentCategoryMaster.new(id: nil)
    assert_not master.valid?
    assert_not_empty master.errors[:id]

    existing = AppDocumentCategoryMaster.first || AppDocumentCategoryMaster.create!(id: "EXISTING")
    duplicate = AppDocumentCategoryMaster.new(id: existing.id.downcase)
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:id]
  end

  test "upcases id before validation" do
    master = AppDocumentCategoryMaster.new(id: "new_category")
    master.valid?
    assert_equal "NEW_CATEGORY", master.id
  end

  test "validates id format" do
    master = AppDocumentCategoryMaster.new(id: "INVALID-ID!")
    assert_not master.valid?
    assert_not_empty master.errors[:id]
  end

  test "root? returns true when parent_id is NEYO" do
    master = AppDocumentCategoryMaster.new(id: "ROOT", parent_id: "NEYO")
    assert_predicate master, :root?

    master.parent_id = "SOME_PARENT"
    assert_not master.root?
  end

  test "parent and children associations" do
    parent = AppDocumentCategoryMaster.create!(id: "PARENT_CAT")
    child = AppDocumentCategoryMaster.create!(id: "CHILD_CAT", parent: parent)

    assert_equal parent, child.parent
    assert_includes parent.children, child
  end

  test "name returns translated string" do
    master = AppDocumentCategoryMaster.new(id: "TEST_CAT")
    # This might depend on your locale file having this key,
    # but the method should at least return a string.
    assert_kind_of String, master.name
  end
end
