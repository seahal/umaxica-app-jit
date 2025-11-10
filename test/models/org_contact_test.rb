require "test_helper"


class OrgContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator OrgContact, :<, GuestsRecord
  end

  test "should downcase email_address before save" do
    contact = OrgContact.new(
      email_address: "TEST@EXAMPLE.COM",
      title: "Test",
      description: "Test description"
    )
    contact.save

    assert_equal "test@example.com", contact.email_address
  end

  test "should downcase telephone_number before save" do
    contact = OrgContact.new(
      telephone_number: "ABC123",
      title: "Test",
      description: "Test description"
    )
    contact.save

    assert_equal "abc123", contact.telephone_number
  end

  test "should handle nil email_address" do
    contact = OrgContact.new(
      email_address: nil,
      title: "Test",
      description: "Test description"
    )

    assert contact.save
    assert_nil contact.email_address
  end

  test "should handle nil telephone_number" do
    contact = OrgContact.new(
      telephone_number: nil,
      title: "Test",
      description: "Test description"
    )

    assert contact.save
    assert_nil contact.telephone_number
  end

  test "should have valid fixtures" do
    contact = org_contacts(:one)

    assert_predicate contact, :valid?
  end

  test "should use UUID as primary key" do
    contact = org_contacts(:one)

    assert_kind_of String, contact.id
    assert_equal 36, contact.id.length
  end

  test "should have timestamps" do
    contact = org_contacts(:one)

    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have all expected attributes" do
    contact = org_contacts(:one)

    assert_respond_to contact, :email_address
    assert_respond_to contact, :telephone_number
    assert_respond_to contact, :title
    assert_respond_to contact, :description
    assert_respond_to contact, :ip_address
  end
  # rubocop:enable Minitest/MultipleAssertions

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    category = OrgContactCategory.create!(title: "org_category")
    contact = OrgContact.new(
      email_address: "org@example.com",
      title: "Org Contact",
      description: "Org description",
      contact_category_title: "org_category"
    )

    assert contact.save
    assert_equal "org_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    status = OrgContactStatus.create!(title: "org_status")
    contact = OrgContact.new(
      email_address: "org@example.com",
      title: "Org Contact",
      description: "Org description",
      contact_status_title: "org_status"
    )

    assert contact.save
    assert_equal "org_status", contact.contact_status_title
  end

  test "should set default contact_category_title when nil" do
    contact = OrgContact.new(
      email_address: "org@example.com",
      title: "Org Contact",
      description: "Org description",
      contact_category_title: nil
    )

    assert contact.save
    assert_equal "NULL_ORG_CATEGORY", contact.contact_category_title
  end

  test "should set default contact_status_title when nil" do
    contact = OrgContact.new(
      email_address: "org@example.com",
      title: "Org Contact",
      description: "Org description",
      contact_status_title: nil
    )

    assert contact.save
    assert_equal "NULL_CONTACT_STATUS", contact.contact_status_title
  end
end
