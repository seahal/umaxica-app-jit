require "test_helper"

class ContactStatusTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator ContactStatus, :<, GuestsRecord
  end

  test "should use title as primary key" do
    assert_equal "title", ContactStatus.primary_key
  end

  test "should create contact status with title" do
    status = ContactStatus.new(title: "pending")

    assert status.save
    assert_equal "pending", status.title
  end

  test "should find contact status by title" do
    status = ContactStatus.create!(title: "approved")
    found = ContactStatus.find("approved")

    assert_equal status.title, found.title
  end

  test "should have unique title" do
    ContactStatus.create!(title: "unique_status_#{SecureRandom.hex(4)}")
    status_title = "duplicate_test_#{SecureRandom.hex(4)}"
    ContactStatus.create!(title: status_title)

    assert_raises(ActiveRecord::RecordNotUnique) do
      ContactStatus.create!(title: status_title)
    end
  end

  test "should have timestamps" do
    status = ContactStatus.create!(title: "test_status")

    assert_respond_to status, :created_at
    assert_respond_to status, :updated_at
    assert_not_nil status.created_at
    assert_not_nil status.updated_at
  end
end
