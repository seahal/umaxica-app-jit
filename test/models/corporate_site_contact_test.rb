require "test_helper"

class CorporateSiteContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContact < GuestsRecord
  end

  test "should have valid fixtures" do
    contact = corporate_site_contacts(:one)
    assert contact.valid?
    assert_equal "general", contact.category
    assert_equal "active", contact.status
  end

  test "should create contact with required attributes" do
    contact = CorporateSiteContact.new(
      category: "inquiry",
      status: "pending"
    )
    assert contact.save
    assert_equal "inquiry", contact.category
    assert_equal "pending", contact.status
  end

  test "should have timestamps" do
    contact = corporate_site_contacts(:one)
    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
    assert_not_nil contact.created_at
    assert_not_nil contact.updated_at
  end

  test "should use UUID as primary key" do
    contact = corporate_site_contacts(:one)
    assert_kind_of String, contact.id
    assert_equal 36, contact.id.length
  end

  test "should have category and status attributes" do
    contact = corporate_site_contacts(:one)
    assert_respond_to contact, :category
    assert_respond_to contact, :status
  end
end
