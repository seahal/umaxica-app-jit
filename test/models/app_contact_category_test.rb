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
