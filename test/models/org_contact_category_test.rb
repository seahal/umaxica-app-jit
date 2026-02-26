# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_categories
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestRecord" do
    assert_operator OrgContactCategory, :<, GuestRecord
  end

  test "should use id as primary key" do
    assert_equal "id", OrgContactCategory.primary_key
  end

  test "should create contact category with id" do
    category = OrgContactCategory.find_or_create_by!(id: OrgContactCategory::ORGANIZATION_INQUIRY)

    assert_equal OrgContactCategory::ORGANIZATION_INQUIRY, category.id
    assert_kind_of Integer, category.id
  end

  test "should find contact category by id" do
    category = OrgContactCategory.create!(id: 998)
    found = OrgContactCategory.find(998)

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    OrgContactCategory.create!(id: 999)

    assert_raises(ActiveRecord::RecordInvalid) do
      OrgContactCategory.create!(id: 999)
    end
  end

  # parent_id column has been removed from org_contact_categories
  # test "parent_id allows blank but enforces max length" do
  #   category = OrgContactCategory.new(id: "NO_PARENT", parent_id: nil)
  #   assert_predicate category, :valid?
  #
  #   category = OrgContactCategory.new(id: "NO_PARENT", parent_id: "")
  #   assert_predicate category, :valid?
  #
  #   category = OrgContactCategory.new(id: "NO_PARENT", parent_id: " ")
  #   assert_predicate category, :valid?
  #
  #   category = OrgContactCategory.new(id: "NO_PARENT", parent_id: "A" * 255)
  #   assert_predicate category, :valid?
  #
  #   category = OrgContactCategory.new(id: "NO_PARENT", parent_id: "A" * 256)
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  # end

  # parent_id column has been removed from org_contact_categories
  # test "destroy is restricted when children exist" do
  #   parent = OrgContactCategory.create!(id: "PARENT")
  #   OrgContactCategory.create!(id: "CHILD", parent_id: parent.id)
  #
  #   assert_not parent.destroy
  #   assert_predicate parent.errors[:base], :any?
  # end

  test "destroy is restricted when contacts exist" do
    category = OrgContactCategory.create!(id: 101)
    status = OrgContactStatus.find_by(id: OrgContactStatus::NOTHING) || OrgContactStatus.create!(id: OrgContactStatus::NOTHING)
    OrgContact.create!(confirm_policy: "1", category_id: category.id, status_id: status.id)

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      category.destroy
    end
  end
end
