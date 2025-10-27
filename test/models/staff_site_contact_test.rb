require "test_helper"

class StaffSiteContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert StaffSiteContact < GuestsRecord
  end

  test "should downcase email_address before save" do
    contact = StaffSiteContact.new(
      email_address: "TEST@EXAMPLE.COM",
      title: "Test",
      description: "Test description"
    )
    contact.save
    assert_equal "test@example.com", contact.email_address
  end

  test "should downcase telephone_number before save" do
    contact = StaffSiteContact.new(
      telephone_number: "ABC123",
      title: "Test",
      description: "Test description"
    )
    contact.save
    assert_equal "abc123", contact.telephone_number
  end

  test "should handle nil email_address" do
    contact = StaffSiteContact.new(
      email_address: nil,
      title: "Test",
      description: "Test description"
    )
    assert contact.save
    assert_nil contact.email_address
  end

  test "should handle nil telephone_number" do
    contact = StaffSiteContact.new(
      telephone_number: nil,
      title: "Test",
      description: "Test description"
    )
    assert contact.save
    assert_nil contact.telephone_number
  end

  test "should have valid fixtures" do
    contact = staff_site_contacts(:one)
    assert contact.valid?
  end

  test "should use UUID as primary key" do
    contact = staff_site_contacts(:one)
    assert_kind_of String, contact.id
    assert_equal 36, contact.id.length
  end

  test "should have timestamps" do
    contact = staff_site_contacts(:one)
    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
  end

  test "should have all expected attributes" do
    contact = staff_site_contacts(:one)
    assert_respond_to contact, :email_address
    assert_respond_to contact, :telephone_number
    assert_respond_to contact, :title
    assert_respond_to contact, :description
    assert_respond_to contact, :ip_address
  end
end
