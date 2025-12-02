require "test_helper"

class ComContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator ComContactCategory, :<, GuestsRecord
  end

  test "should use title as primary key" do
    assert_equal "title", ComContactCategory.primary_key
  end

  test "should create contact category with title" do
    category = ComContactCategory.new(title: "com_inquiry")

    assert category.save
    assert_equal "com_inquiry", category.title
  end

  test "should find contact category by title" do
    category = ComContactCategory.create!(title: "com_support")
    found = ComContactCategory.find("com_support")

    assert_equal category.title, found.title
  end

  test "should have unique title" do
    ComContactCategory.create!(title: "unique_com_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_com_test_#{SecureRandom.hex(4)}"
    ComContactCategory.create!(title: category_title)

    assert_raises(ActiveRecord::RecordNotUnique) do
      ComContactCategory.create!(title: category_title)
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    category = ComContactCategory.create!(title: "test_com_category")

    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions
end
