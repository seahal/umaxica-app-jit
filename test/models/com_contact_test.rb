require "test_helper"


class ComContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    # Create contact first
    contact = ComContact.new(**attrs.except(:com_contact_emails, :com_contact_telephones))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.save!

    # Create email and telephone associated with the contact
    unless attrs.key?(:com_contact_emails)
      ComContactEmail.create!(
        com_contact: contact,
        email_address: "test@example.com",
        expires_at: 1.day.from_now
      )
    end

    unless attrs.key?(:com_contact_telephones)
      ComContactTelephone.create!(
        com_contact: contact,
        telephone_number: "+1234567890",
        expires_at: 1.day.from_now
      )
    end

    contact
  end

  def sample_category
    com_contact_categories(:one).title
  end

  def sample_status
    com_contact_statuses(:none).title
  end

  test "should inherit from GuestsRecord" do
    assert_operator ComContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = com_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "CORPORATE_INQUIRY", contact.contact_category_title
    assert_equal "NULL_COM_STATUS", contact.contact_status_title
  end

  test "should create contact with relationship titles" do
    contact = ComContact.new(
      contact_category_title: sample_category,
      contact_status_title: sample_status,
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal sample_category, contact.contact_category_title
    assert_equal sample_status, contact.contact_status_title
  end

  test "should set default category and status when nil" do
    contact = ComContact.new(
      contact_category_title: nil,
      contact_status_title: nil,
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_COM_CATEGORY", contact.contact_category_title
    assert_equal "NULL_COM_STATUS", contact.contact_status_title
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = com_contacts(:one)

    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
    assert_not_nil contact.created_at
    assert_not_nil contact.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should use UUID as primary key" do
    contact = com_contacts(:one)

    assert_kind_of String, contact.id
    assert_equal 36, contact.id.length
  end

  test "should expose relationship title attributes" do
    contact = com_contacts(:one)

    assert_respond_to contact, :contact_category_title
    assert_respond_to contact, :contact_status_title
  end

  # Association tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should have many com_contact_emails" do
    contact = build_contact

    assert_respond_to contact, :com_contact_emails
    assert_equal 1, contact.com_contact_emails.count
    assert_instance_of ComContactEmail, contact.com_contact_emails.first

    # Test adding another email
    ComContactEmail.create!(
      com_contact: contact,
      email_address: "another@example.com",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.com_contact_emails.count
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should have many com_contact_telephones" do
    contact = build_contact

    assert_respond_to contact, :com_contact_telephones
    assert_equal 1, contact.com_contact_telephones.count
    assert_instance_of ComContactTelephone, contact.com_contact_telephones.first

    # Test adding another telephone
    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.com_contact_telephones.count
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have many com_contact_topics" do
    contact = build_contact

    topic1 = ComContactTopic.create!(com_contact: contact)
    topic2 = ComContactTopic.create!(com_contact: contact)

    assert_equal 2, contact.com_contact_topics.count
    assert_includes contact.com_contact_topics, topic1
    assert_includes contact.com_contact_topics, topic2
  end

  test "should destroy associated topics when contact is destroyed" do
    contact = build_contact

    topic = ComContactTopic.create!(com_contact: contact)

    topic_id = topic.id
    contact.destroy

    assert_nil ComContactTopic.find_by(id: topic_id)
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
    ComContactCategory.create!(title: "com_category")

    contact = ComContact.new(
      contact_category_title: "com_category",
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "com_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    ComContactStatus.create!(title: "com_status")

    contact = ComContact.new(
      contact_status_title: "com_status",
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "com_status", contact.contact_status_title
  end

  test "should set default contact_category_title when nil" do
    contact = ComContact.new(
      contact_category_title: nil,
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_COM_CATEGORY", contact.contact_category_title
  end

  test "should set default contact_status_title when nil" do
    contact = ComContact.new(
      contact_status_title: nil,
      confirm_policy: "1"
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_COM_STATUS", contact.contact_status_title
  end

  # Validation tests
  test "should allow contact without email addresses" do
    contact = ComContact.new(confirm_policy: "1")

    assert contact.save
    assert_equal 0, contact.com_contact_emails.count
  end

  test "should allow contact without telephone numbers" do
    contact = ComContact.new(confirm_policy: "1")

    assert contact.save
    assert_equal 0, contact.com_contact_telephones.count
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should allow contact with multiple emails and telephones" do
    contact = ComContact.new(confirm_policy: "1")
    contact.save!

    email1 = ComContactEmail.create!(
      com_contact: contact,
      email_address: "first@example.com",
      expires_at: 1.day.from_now
    )

    email2 = ComContactEmail.create!(
      com_contact: contact,
      email_address: "second@example.com",
      expires_at: 1.day.from_now
    )

    telephone1 = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone2 = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.com_contact_emails.count
    assert_includes contact.com_contact_emails, email1
    assert_includes contact.com_contact_emails, email2

    assert_equal 2, contact.com_contact_telephones.count
    assert_includes contact.com_contact_telephones, telephone1
    assert_includes contact.com_contact_telephones, telephone2
  end
  # rubocop:enable Minitest/MultipleAssertions
end
