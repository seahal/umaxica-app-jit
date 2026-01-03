# == Schema Information
#
# Table name: org_timeline_tag_masters
#
#  id         :string(255)      not null, primary key
#  parent_id  :string(255)      default("none"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_org_timeline_tag_masters_on_parent_id  (parent_id)
#

# frozen_string_literal: true

require "test_helper"

class OrgTimelineTagMasterTest < ActiveSupport::TestCase
  fixtures :org_timeline_tag_masters

  test "validates id presence and uniqueness" do
    master = OrgTimelineTagMaster.new(id: nil)
    assert_not master.valid?
    assert_not_empty master.errors[:id]

    existing = OrgTimelineTagMaster.first || OrgTimelineTagMaster.create!(id: "EXISTING")
    duplicate = OrgTimelineTagMaster.new(id: existing.id.downcase)
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:id]
  end

  test "upcases id before validation" do
    master = OrgTimelineTagMaster.new(id: "new_category")
    master.valid?
    assert_equal "NEW_CATEGORY", master.id
  end

  test "validates id format" do
    master = OrgTimelineTagMaster.new(id: "INVALID-ID!")
    assert_not master.valid?
    assert_not_empty master.errors[:id]
  end

  test "root? returns true when parent_id is NEYO" do
    master = OrgTimelineTagMaster.new(id: "ROOT", parent_id: "NEYO")
    assert_predicate master, :root?

    master.parent_id = "SOME_PARENT"
    assert_not master.root?
  end

  test "parent and children associations" do
    parent = OrgTimelineTagMaster.create!(id: "PARENT_CAT")
    child = OrgTimelineTagMaster.create!(id: "CHILD_CAT", parent: parent)

    assert_equal parent, child.parent
    assert_includes parent.children, child
  end

  test "name returns translated string" do
    master = OrgTimelineTagMaster.new(id: "TEST_CAT")
    # This might depend on your locale file having this key,
    # but the method should at least return a string.
    assert_kind_of String, master.name
  end
end
