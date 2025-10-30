require "test_helper"

class ContactCategoryTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert ContactCategory < GuestsRecord
  end

  test "should use title as primary key" do
    assert_equal "title", ContactCategory.primary_key
  end

  test "should create contact category with title" do
    category = ContactCategory.new(title: "inquiry")
    assert category.save
    assert_equal "inquiry", category.title
  end

  test "should find contact category by title" do
    category = ContactCategory.create!(title: "support")
    found = ContactCategory.find("support")
    assert_equal category.title, found.title
  end

  test "should have unique title" do
    ContactCategory.create!(title: "unique_category_#{SecureRandom.hex(4)}")
    category_title = "duplicate_test_#{SecureRandom.hex(4)}"
    ContactCategory.create!(title: category_title)

    assert_raises(ActiveRecord::RecordNotUnique) do
      ContactCategory.create!(title: category_title)
    end
  end

  test "should have timestamps" do
    category = ContactCategory.create!(title: "test_category")
    assert_respond_to category, :created_at
    assert_respond_to category, :updated_at
    assert_not_nil category.created_at
    assert_not_nil category.updated_at
  end
end
