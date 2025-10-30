require "test_helper"


class CorporateSiteContactTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator CorporateSiteContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = corporate_site_contacts(:one)

    assert_predicate contact, :valid?
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

  # rubocop:disable Minitest/MultipleAssertions
  test "should have state machine methods" do
    contact = corporate_site_contacts(:one)

    assert_respond_to contact, :email_pending?
    assert_respond_to contact, :email_verified?
    assert_respond_to contact, :phone_verified?
    assert_respond_to contact, :completed?
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should transition from email_pending to email_verified" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    assert_predicate contact, :can_verify_email?
    assert contact.verify_email!
    assert_predicate contact, :email_verified?
  end

  test "should transition from email_verified to phone_verified" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_verified")

    assert_predicate contact, :can_verify_phone?
    assert contact.verify_phone!
    assert_predicate contact, :phone_verified?
  end

  test "should transition from phone_verified to completed" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")

    assert_predicate contact, :can_complete?
    assert contact.complete!
    assert_predicate contact, :completed?
  end

  test "should not allow invalid transitions" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    assert_not contact.can_verify_phone?
    assert_not contact.verify_phone!
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should generate and verify final token" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    raw_token = contact.generate_final_token

    assert_not_nil raw_token
    assert_not_nil contact.token_digest
    assert_not_nil contact.token_expires_at
    assert_not contact.token_viewed?

    # Verify correct token
    assert contact.verify_token(raw_token)
    assert_predicate contact, :token_viewed?

    # Cannot verify again
    assert_not contact.verify_token(raw_token)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should reject invalid token" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    contact.generate_final_token

    assert_not contact.verify_token("wrong_token")
    assert_not contact.token_viewed?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = corporate_site_contacts(:one)

    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
    assert_not_nil contact.created_at
    assert_not_nil contact.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

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

  # Association tests
  test "should have many corporate_site_contact_emails" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    email1 = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "test1@example.com",
      expires_at: 1.day.from_now
    )

    email2 = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "test2@example.com",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.corporate_site_contact_emails.count
    assert_includes contact.corporate_site_contact_emails, email1
    assert_includes contact.corporate_site_contact_emails, email2
  end

  test "should destroy associated emails when contact is destroyed" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "destroy@example.com",
      expires_at: 1.day.from_now
    )

    email_id = email.id
    contact.destroy

    assert_nil CorporateSiteContactEmail.find_by(id: email_id)
  end

  test "should have many corporate_site_contact_telephones" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    phone1 = CorporateSiteContactTelephone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    phone2 = CorporateSiteContactTelephone.create!(
      corporate_site_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.corporate_site_contact_telephones.count
    assert_includes contact.corporate_site_contact_telephones, phone1
    assert_includes contact.corporate_site_contact_telephones, phone2
  end

  test "should destroy associated telephones when contact is destroyed" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    phone = CorporateSiteContactTelephone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    phone_id = phone.id
    contact.destroy

    assert_nil CorporateSiteContactTelephone.find_by(id: phone_id)
  end

  test "should have many corporate_site_contact_topics" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    topic1 = CorporateSiteContactTopic.create!(corporate_site_contact: contact)
    topic2 = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_equal 2, contact.corporate_site_contact_topics.count
    assert_includes contact.corporate_site_contact_topics, topic1
    assert_includes contact.corporate_site_contact_topics, topic2
  end

  test "should destroy associated topics when contact is destroyed" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    topic_id = topic.id
    contact.destroy

    assert_nil CorporateSiteContactTopic.find_by(id: topic_id)
  end

  # Validation tests
  test "should validate inclusion of status" do
    contact = CorporateSiteContact.new(category: "general")
    contact.status = "invalid_status"

    assert_not contact.valid?
    assert_predicate contact.errors[:status], :any?, "status should have validation errors for invalid value"
  end

  test "should validate inclusion of category" do
    contact = CorporateSiteContact.new(status: "email_pending")
    contact.category = "invalid_category"

    assert_not contact.valid?
    assert_predicate contact.errors[:category], :any?, "category should have validation errors for invalid value"
  end

  # Token expiration tests
  test "token_expired? should return false when token is not expired" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    raw_token = contact.generate_final_token

    assert_not contact.token_expired?
  end

  test "token_expired? should return true when token is expired" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    raw_token = contact.generate_final_token

    contact.update!(token_expires_at: 1.hour.ago)

    assert_predicate contact, :token_expired?
  end

  test "token_expired? should return false when token_expires_at is nil" do
    contact = CorporateSiteContact.create!(category: "general", status: "email_pending")

    assert_not contact.token_expired?
  end

  test "should not verify token when token is expired" do
    contact = CorporateSiteContact.create!(category: "general", status: "phone_verified")
    raw_token = contact.generate_final_token

    contact.update!(token_expires_at: 1.hour.ago)

    assert_not contact.verify_token(raw_token)
  end

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    category = ContactCategory.create!(title: "corporate_category")
    contact = CorporateSiteContact.new(
      category: "general",
      status: "email_pending",
      contact_category_title: "corporate_category"
    )

    assert contact.save
    assert_equal "corporate_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    status = ContactStatus.create!(title: "corporate_status")
    contact = CorporateSiteContact.new(
      category: "general",
      status: "email_pending",
      contact_status_title: "corporate_status"
    )

    assert contact.save
    assert_equal "corporate_status", contact.contact_status_title
  end

  test "should allow nil for contact_category_title" do
    contact = CorporateSiteContact.new(
      category: "general",
      status: "email_pending",
      contact_category_title: nil
    )

    assert contact.save
    assert_nil contact.contact_category_title
  end

  test "should allow nil for contact_status_title" do
    contact = CorporateSiteContact.new(
      category: "general",
      status: "email_pending",
      contact_status_title: nil
    )

    assert contact.save
    assert_nil contact.contact_status_title
  end
end
