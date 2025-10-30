require "test_helper"


class StaffSiteContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator StaffSiteContact, :<, GuestsRecord
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

    assert_predicate contact, :valid?
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

  # rubocop:disable Minitest/MultipleAssertions
  test "should have all expected attributes" do
    contact = staff_site_contacts(:one)

    assert_respond_to contact, :email_address
    assert_respond_to contact, :telephone_number
    assert_respond_to contact, :title
    assert_respond_to contact, :description
    assert_respond_to contact, :ip_address
  end
  # rubocop:enable Minitest/MultipleAssertions

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    category = ContactCategory.create!(title: "staff_category")
    contact = StaffSiteContact.new(
      email_address: "staff@example.com",
      title: "Staff Contact",
      description: "Staff description",
      contact_category_title: "staff_category"
    )

    assert contact.save
    assert_equal "staff_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    status = ContactStatus.create!(title: "staff_status")
    contact = StaffSiteContact.new(
      email_address: "staff@example.com",
      title: "Staff Contact",
      description: "Staff description",
      contact_status_title: "staff_status"
    )

    assert contact.save
    assert_equal "staff_status", contact.contact_status_title
  end

  test "should allow nil for contact_category_title" do
    contact = StaffSiteContact.new(
      email_address: "staff@example.com",
      title: "Staff Contact",
      description: "Staff description",
      contact_category_title: nil
    )

    assert contact.save
    assert_nil contact.contact_category_title
  end

  test "should allow nil for contact_status_title" do
    contact = StaffSiteContact.new(
      email_address: "staff@example.com",
      title: "Staff Contact",
      description: "Staff description",
      contact_status_title: nil
    )

    assert contact.save
    assert_nil contact.contact_status_title
  end
end
