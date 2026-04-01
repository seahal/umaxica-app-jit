# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_categories
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestRecord" do
    assert_operator ComContactCategory, :<, GuestRecord
  end

  test "should use id as primary key" do
    assert_equal "id", ComContactCategory.primary_key
  end

  test "should create contact category with id" do
    category = ComContactCategory.new(id: 99)

    assert category.save
    assert_equal 99, category.id
  end

  test "should find contact category by id" do
    category = ComContactCategory.create!(id: 100)
    found = ComContactCategory.find(100)

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    ComContactCategory.create!(id: 99)

    assert_raises(ActiveRecord::RecordNotUnique) do
      ComContactCategory.create!(id: 99)
    end
  end

  # parent_id column has been removed from com_contact_categories
  # test "parent_id allows blank but enforces max length" do
  #   category = ComContactCategory.new(id: "NO_PARENT", parent_id: nil)
  #   assert_predicate category, :valid?
  #
  #   category = ComContactCategory.new(id: "NO_PARENT", parent_id: "")
  #   assert_predicate category, :valid?
  #
  #   category = ComContactCategory.new(id: "NO_PARENT", parent_id: " ")
  #   assert_predicate category, :valid?
  #
  #   category = ComContactCategory.new(id: "NO_PARENT", parent_id: "A" * 255)
  #   assert_predicate category, :valid?
  #
  #   category = ComContactCategory.new(id: "NO_PARENT", parent_id: "A" * 256)
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  # end

  # parent_id column has been removed from com_contact_categories
  # test "destroy is restricted when children exist" do
  #   parent = ComContactCategory.create!(id: "PARENT")
  #   ComContactCategory.create!(id: "CHILD", parent_id: parent.id)
  #
  #   assert_not parent.destroy
  #   assert_predicate parent.errors[:base], :any?
  # end

  test "destroy is restricted when contacts exist" do
    category = ComContactCategory.create!(id: 101)
    status = ComContactStatus.find_by(id: ComContactStatus::NOTHING) || ComContactStatus.create!(id: ComContactStatus::NOTHING)
    ComContact.create!(confirm_policy: "1", category_id: category.id, status_id: status.id)

    assert_raises(ActiveRecord::DeleteRestrictionError) { category.destroy }
  end

  # test "should have timestamps" do
  #   category = ComContactCategory.create!(id: "test_com_category")
  #
  #   assert_respond_to category, :created_at
  #   assert_respond_to category, :updated_at
  #   assert_not_nil category.created_at
  #   assert_not_nil category.updated_at
  # end
end
