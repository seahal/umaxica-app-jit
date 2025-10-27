require "test_helper"

class CorporateSiteContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContact < GuestsRecord
  end

  test "should have valid fixtures" do
    contact = corporate_site_contacts(:one)
    assert contact.valid?
    assert_equal "general", contact.category
    assert_equal "email_pending", contact.status
  end

  test "should create contact with required attributes" do
    contact = CorporateSiteContact.new(
      category: "inquiry",
      status: "email_verified"
    )
    assert contact.save
    assert_equal "inquiry", contact.category
    assert_equal "email_verified", contact.status
  end

  test "should default to email_pending status" do
    contact = CorporateSiteContact.new(category: "general")
    assert contact.save
    assert_equal "email_pending", contact.status
  end

  test "should default to general category" do
    contact = CorporateSiteContact.new(status: "email_pending")
    assert contact.save
    assert_equal "general", contact.category
  end

  test "should have state machine methods" do
    contact = corporate_site_contacts(:one)
    assert_respond_to contact, :email_pending?
    assert_respond_to contact, :email_verified?
    assert_respond_to contact, :phone_verified?
    assert_respond_to contact, :completed?
  end

  test "should transition from email_pending to email_verified" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")
    assert contact.can_verify_email?
    assert contact.verify_email!
    assert contact.email_verified?
  end

  test "should transition from email_verified to phone_verified" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_verified")
    assert contact.can_verify_phone?
    assert contact.verify_phone!
    assert contact.phone_verified?
  end

  test "should transition from phone_verified to completed" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    assert contact.can_complete?
    assert contact.complete!
    assert contact.completed?
  end

  test "should not allow invalid transitions" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")
    assert_not contact.can_verify_phone?
    assert_not contact.verify_phone!
  end

  test "should generate and verify final token" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    raw_token = contact.generate_final_token

    assert_not_nil raw_token
    assert_not_nil contact.token_digest
    assert_not_nil contact.token_expires_at
    assert_not contact.token_viewed?

    # Verify correct token
    assert contact.verify_token(raw_token)
    assert contact.token_viewed?

    # Cannot verify again
    assert_not contact.verify_token(raw_token)
  end

  test "should reject invalid token" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    contact.generate_final_token

    assert_not contact.verify_token("wrong_token")
    assert_not contact.token_viewed?
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
