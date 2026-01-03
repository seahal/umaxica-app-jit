# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_categories
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default(""), not null
#  position    :integer          default(0), not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_com_contact_categories_on_parent_id  (parent_id)
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
    category = ComContactCategory.new(id: "com_inquiry")

    assert category.save
    assert_equal "COM_INQUIRY", category.id
  end

  test "should find contact category by id" do
    category = ComContactCategory.create!(id: "com_support")
    found = ComContactCategory.find("COM_SUPPORT")

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    ComContactCategory.create!(id: "unique_com_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_com_test_#{SecureRandom.hex(4)}"
    ComContactCategory.create!(id: category_title)

    assert_raises(ActiveRecord::RecordInvalid) do
      ComContactCategory.create!(id: category_title)
    end
  end

  test "id is invalid when nil or blank" do
    category = ComContactCategory.new(id: nil)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = ComContactCategory.new(id: "")
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = ComContactCategory.new(id: " ")
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?
  end

  test "id enforces length and format boundaries" do
    category = ComContactCategory.new(id: "A" * 255)
    assert_predicate category, :valid?

    category = ComContactCategory.new(id: "A" * 256)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = ComContactCategory.new(id: "BAD-ID")
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?
  end

  test "id uniqueness is case-insensitive" do
    ComContactCategory.create!(id: "CASE_CHECK")

    duplicate = ComContactCategory.new(id: "case_check")
    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:id], :any?
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
    category = ComContactCategory.create!(id: "CONTACT_PARENT")
    status = ComContactStatus.create!(id: "ACTIVE_TEST")
    ComContact.create!(confirm_policy: "1", category_id: category.id, status_id: status.id)

    assert_not category.destroy
    assert_predicate category.errors[:base], :any?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    category = ComContactCategory.create!(id: "test_com_category")

    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
