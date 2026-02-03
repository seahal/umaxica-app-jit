# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestRecord" do
    assert_operator AppContactCategory, :<, GuestRecord
  end

  test "should use id as primary key" do
    assert_equal "id", AppContactCategory.primary_key
  end

  test "should create contact category with id" do
    category = AppContactCategory.new(id: 99)

    assert category.save
    assert_equal 99, category.id
  end

  test "should find contact category by id" do
    category = AppContactCategory.create!(id: 100)
    found = AppContactCategory.find(100)

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    AppContactCategory.create!(id: 101)

    assert_raises(ActiveRecord::RecordNotUnique) do
      AppContactCategory.create!(id: 101)
    end
  end

  # parent_id column has been removed from app_contact_categories
  # test "parent_id is required" do
  #   category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: nil)
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  #
  #   category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "")
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  #
  #   category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: " ")
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  # end

  # parent_id column has been removed from app_contact_categories
  # test "parent_id respects length bounds" do
  #   category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "A" * 255)
  #   assert_predicate category, :valid?
  #
  #   category = AppContactCategory.new(id: "REQUIRES_PARENT", parent_id: "A" * 256)
  #   assert_not category.valid?
  #   assert_predicate category.errors[:parent_id], :any?
  # end

  # parent_id column has been removed from app_contact_categories
  # test "destroy is restricted when children exist" do
  #   parent = AppContactCategory.create!(id: "PARENT")
  #   AppContactCategory.create!(id: "CHILD", parent_id: parent.id)
  #
  #   assert_not parent.destroy
  #   assert_predicate parent.errors[:base], :any?
  # end

  test "destroy is restricted when contacts exist" do
    category = AppContactCategory.create!(id: 102)
    status = AppContactStatus.find_or_create_by!(id: AppContactStatus::NEYO)
    AppContact.create!(confirm_policy: "1", category_id: category.id, status_id: status.id)

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      category.destroy
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  # test "should have timestamps" do
  #   category = AppContactCategory.create!(id: "test_app_category")
  #
  #   assert_respond_to category, :created_at
  #   assert_respond_to category, :updated_at
  #   assert_not_nil category.created_at
  #   assert_not_nil category.updated_at
  # end
  # rubocop:enable Minitest/MultipleAssertions
end
