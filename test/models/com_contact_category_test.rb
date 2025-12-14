require "test_helper"

class ComContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator ComContactCategory, :<, GuestsRecord
  end

  test "should use title as primary key" do
    assert_equal "title", ComContactCategory.primary_key
  end

  test "should create contact category with title" do
    category = ComContactCategory.new(id: "com_inquiry")

    assert category.save
    assert_equal "COM_INQUIRY", category.id
  end

  test "should find contact category by title" do
    category = ComContactCategory.create!(id: "com_support")
    found = ComContactCategory.find("COM_SUPPORT")

    assert_equal category.id, found.id
  end

  test "should have unique title" do
    ComContactCategory.create!(id: "unique_com_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_com_test_#{SecureRandom.hex(4)}"
    ComContactCategory.create!(id: category_title)

    assert_raises(ActiveRecord::RecordInvalid) do
      ComContactCategory.create!(id: category_title)
    end
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
