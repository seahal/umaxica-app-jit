require "test_helper"


class CorporateSiteContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    CorporateSiteContact.create!(**attrs)
  end

  def sample_category
    contact_categories(:one).title
  end

  def sample_status
    contact_statuses(:one).title
  end

  test "should inherit from GuestsRecord" do
    assert_operator CorporateSiteContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = corporate_site_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "CORPORATE_CATEGORY", contact.contact_category_title
    assert_equal "CORPORATE_SITE_STATUS", contact.contact_status_title
  end

  test "should create contact with relationship titles" do
    contact = CorporateSiteContact.new(
      contact_category_title: sample_category,
      contact_status_title: sample_status
    )

    assert contact.save
    assert_equal sample_category, contact.contact_category_title
    assert_equal sample_status, contact.contact_status_title
  end

  test "should allow nil relationship titles" do
    contact = CorporateSiteContact.new(
      contact_category_title: nil,
      contact_status_title: nil
    )

    assert contact.save
    assert_nil contact.contact_category_title
    assert_nil contact.contact_status_title
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

  test "should expose relationship title attributes" do
    contact = corporate_site_contacts(:one)

    assert_respond_to contact, :contact_category_title
    assert_respond_to contact, :contact_status_title
  end

  # Association tests
  test "should have many corporate_site_contact_emails" do
    contact = build_contact

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
    contact = build_contact

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
    contact = build_contact

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
    contact = build_contact

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
    contact = build_contact

    topic1 = CorporateSiteContactTopic.create!(corporate_site_contact: contact)
    topic2 = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_equal 2, contact.corporate_site_contact_topics.count
    assert_includes contact.corporate_site_contact_topics, topic1
    assert_includes contact.corporate_site_contact_topics, topic2
  end

  test "should destroy associated topics when contact is destroyed" do
    contact = build_contact

    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    topic_id = topic.id
    contact.destroy

    assert_nil CorporateSiteContactTopic.find_by(id: topic_id)
  end

  # Token behaviour tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should generate and verify final token" do
    contact = build_contact
    raw_token = contact.generate_final_token

    assert_not_nil raw_token
    assert_not_nil contact.token_digest
    assert_not_nil contact.token_expires_at
    assert_not contact.token_viewed?

    assert contact.verify_token(raw_token)
    assert_predicate contact, :token_viewed?
    assert_not contact.verify_token(raw_token)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should reject invalid token" do
    contact = build_contact
    contact.generate_final_token

    assert_not contact.verify_token("wrong_token")
    assert_not contact.token_viewed?
  end

  test "token_expired? should return false when token is not expired" do
    contact = build_contact
    contact.generate_final_token

    assert_not contact.token_expired?
  end

  test "token_expired? should return true when token is expired" do
    contact = build_contact
    contact.generate_final_token

    contact.update!(token_expires_at: 1.hour.ago)

    assert_predicate contact, :token_expired?
  end

  test "token_expired? should return false when token_expires_at is nil" do
    contact = build_contact

    assert_not contact.token_expired?
  end

  test "should not verify token when token is expired" do
    contact = build_contact
    raw_token = contact.generate_final_token

    contact.update!(token_expires_at: 1.hour.ago)

    assert_not contact.verify_token(raw_token)
  end

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    ContactCategory.create!(title: "corporate_category")

    contact = CorporateSiteContact.new(
      contact_category_title: "corporate_category"
    )

    assert contact.save
    assert_equal "corporate_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    ContactStatus.create!(title: "corporate_status")

    contact = CorporateSiteContact.new(
      contact_status_title: "corporate_status"
    )

    assert contact.save
    assert_equal "corporate_status", contact.contact_status_title
  end

  test "should allow nil for contact_category_title" do
    contact = CorporateSiteContact.new(
      contact_category_title: nil
    )

    assert contact.save
    assert_nil contact.contact_category_title
  end

  test "should allow nil for contact_status_title" do
    contact = CorporateSiteContact.new(
      contact_status_title: nil
    )

    assert contact.save
    assert_nil contact.contact_status_title
  end
end
