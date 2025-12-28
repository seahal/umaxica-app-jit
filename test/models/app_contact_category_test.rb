# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default("00000000-0000-0000-0000-000000000000"), not null
#  position    :integer          default(0), not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_app_contact_categories_on_parent_id  (parent_id)
#

require "test_helper"

class AppContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator AppContactCategory, :<, GuestsRecord
  end

  test "should use id as primary key" do
    assert_equal "id", AppContactCategory.primary_key
  end

  test "should create contact category with id" do
    category = AppContactCategory.new(id: "app_inquiry")

    assert category.save
    assert_equal "APP_INQUIRY", category.id
  end

  test "should find contact category by id" do
    category = AppContactCategory.create!(id: "app_support")
    found = AppContactCategory.find("APP_SUPPORT")

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    AppContactCategory.create!(id: "unique_app_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_app_test_#{SecureRandom.hex(4)}"
    AppContactCategory.create!(id: category_title)

    assert_raises(ActiveRecord::RecordInvalid) do
      AppContactCategory.create!(id: category_title)
    end
  end

  test "id is invalid when nil or blank" do
    category = AppContactCategory.new(id: nil, parent_id: AppContactCategory::NIL_UUID)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = AppContactCategory.new(id: "", parent_id: AppContactCategory::NIL_UUID)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = AppContactCategory.new(id: " ", parent_id: AppContactCategory::NIL_UUID)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?
  end

  test "id enforces length and format boundaries" do
    category = AppContactCategory.new(id: "A" * 255, parent_id: AppContactCategory::NIL_UUID)
    assert_predicate category, :valid?

    category = AppContactCategory.new(id: "A" * 256, parent_id: AppContactCategory::NIL_UUID)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?

    category = AppContactCategory.new(id: "BAD-ID", parent_id: AppContactCategory::NIL_UUID)
    assert_not category.valid?
    assert_predicate category.errors[:id], :any?
  end

  test "id uniqueness is case-insensitive" do
    AppContactCategory.create!(id: "CASE_CHECK")

    duplicate = AppContactCategory.new(id: "case_check", parent_id: AppContactCategory::NIL_UUID)
    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "parent_id is required" do
    category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: nil)
    assert_not category.valid?
    assert_predicate category.errors[:parent_id], :any?

    category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "")
    assert_not category.valid?
    assert_predicate category.errors[:parent_id], :any?

    category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: " ")
    assert_not category.valid?
    assert_predicate category.errors[:parent_id], :any?
  end

  test "parent_id respects length bounds" do
    category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "A" * 255)
    assert_predicate category, :valid?

    category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "A" * 256)
    assert_not category.valid?
    assert_predicate category.errors[:parent_id], :any?
  end

  test "destroy is restricted when children exist" do
    parent = AppContactCategory.create!(id: "PARENT", parent_id: AppContactCategory::NIL_UUID)
    AppContactCategory.create!(id: "CHILD", parent_id: parent.id)

    assert_not parent.destroy
    assert_predicate parent.errors[:base], :any?
  end

  test "destroy raises when contacts enforce non-null category_id" do
    category = AppContactCategory.create!(id: "CONTACT_PARENT", parent_id: AppContactCategory::NIL_UUID)
    status = AppContactStatus.create!(id: "ACTIVE")
    AppContact.create!(confirm_policy: "1", category_id: category.id, status_id: status.id)

    assert_raises(ActiveRecord::StatementInvalid) do
      category.destroy
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    category = AppContactCategory.create!(id: "test_app_category")

    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
