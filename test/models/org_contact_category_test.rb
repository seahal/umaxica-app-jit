# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_categories
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
#  index_org_contact_categories_on_parent_id  (parent_id)
#

require "test_helper"

class OrgContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator OrgContactCategory, :<, GuestsRecord
  end

  test "should use id as primary key" do
    assert_equal "id", OrgContactCategory.primary_key
  end

  test "should create contact category with id" do
    category = OrgContactCategory.new(id: "org_inquiry")

    assert category.save
    assert_equal "ORG_INQUIRY", category.id
  end

  test "should find contact category by id" do
    category = OrgContactCategory.create!(id: "org_support")
    found = OrgContactCategory.find("ORG_SUPPORT")

    assert_equal category.id, found.id
  end

  test "should have unique id" do
    OrgContactCategory.create!(id: "unique_org_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_org_test_#{SecureRandom.hex(4)}"
    OrgContactCategory.create!(id: category_title)

    assert_raises(ActiveRecord::RecordInvalid) do
      OrgContactCategory.create!(id: category_title)
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    category = OrgContactCategory.create!(id: "test_org_category")

    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
