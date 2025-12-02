require "test_helper"

class OrgContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator OrgContactCategory, :<, GuestsRecord
  end

  test "should use title as primary key" do
    assert_equal "title", OrgContactCategory.primary_key
  end

  test "should create contact category with title" do
    category = OrgContactCategory.new(title: "org_inquiry")

    assert category.save
    assert_equal "org_inquiry", category.title
  end

  test "should find contact category by title" do
    category = OrgContactCategory.create!(title: "org_support")
    found = OrgContactCategory.find("org_support")

    assert_equal category.title, found.title
  end

  test "should have unique title" do
    OrgContactCategory.create!(title: "unique_org_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_org_test_#{SecureRandom.hex(4)}"
    OrgContactCategory.create!(title: category_title)

    assert_raises(ActiveRecord::RecordNotUnique) do
      OrgContactCategory.create!(title: category_title)
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    category = OrgContactCategory.create!(title: "test_org_category")

    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
