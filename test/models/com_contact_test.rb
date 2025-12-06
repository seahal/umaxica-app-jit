require "test_helper"

class ComContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    # Create contact first
    contact = ComContact.new(**attrs.except(:com_contact_email, :com_contact_telephone))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.save!

    # Create email and telephone associated with the contact
    unless attrs.key?(:com_contact_email)
      ComContactEmail.create!(
        com_contact: contact,
        email_address: "test@example.com",
        expires_at: 1.day.from_now
      )
    end

    unless attrs.key?(:com_contact_telephone)
      ComContactTelephone.create!(
        com_contact: contact,
        telephone_number: "+1234567890",
        expires_at: 1.day.from_now
      )
    end

    contact
  end

  def sample_category
    com_contact_categories(:SECURITY_ISSUE).title
  end

  def sample_status
    com_contact_statuses(:NONE).title
  end

  test "should inherit from GuestsRecord" do
    assert_operator ComContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = com_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "SECURITY_ISSUE", contact.contact_category_title
    assert_equal "NONE", contact.contact_status_title
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

    assert_equal "NONE", contact.contact_category_title
    assert_equal "NONE", contact.contact_status_title
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
  test "should have one com_contact_email" do
    contact = build_contact

    assert_respond_to contact, :com_contact_email
    assert_not_nil contact.com_contact_email
    assert_instance_of ComContactEmail, contact.com_contact_email
    assert_equal "test@example.com", contact.com_contact_email.email_address
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should have one com_contact_telephone" do
    contact = build_contact

    assert_respond_to contact, :com_contact_telephone
    assert_not_nil contact.com_contact_telephone
    assert_instance_of ComContactTelephone, contact.com_contact_telephone
    assert_equal "+1234567890", contact.com_contact_telephone.telephone_number
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
    ComContactStatus.create!(title: "SECURITY_ISSUE")

    contact = ComContact.new(
      contact_status_title: "SECURITY_ISSUE",
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

    assert_equal "SECURITY_ISSUE", contact.contact_status_title
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

    assert_equal "NONE", contact.contact_category_title
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

    assert_equal "NONE", contact.contact_status_title
  end

  # Validation tests
  test "should allow contact without email address" do
    contact = ComContact.new(confirm_policy: "1")

    assert contact.save
    assert_nil contact.com_contact_email
  end

  test "should allow contact without telephone number" do
    contact = ComContact.new(confirm_policy: "1")

    assert contact.save
    assert_nil contact.com_contact_telephone
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should allow contact with email and telephone" do
    contact = ComContact.new(confirm_policy: "1")
    contact.save!

    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_not_nil contact.com_contact_email
    assert_equal email, contact.com_contact_email
    assert_equal "test@example.com", contact.com_contact_email.email_address

    assert_not_nil contact.com_contact_telephone
    assert_equal telephone, contact.com_contact_telephone
    assert_equal "+1234567890", contact.com_contact_telephone.telephone_number
  end
  # rubocop:enable Minitest/MultipleAssertions
  # Validation: confirm_policy
  test "should require confirm_policy to be accepted" do
    contact = ComContact.new(
      confirm_policy: "0",
      contact_category_title: sample_category,
      contact_status_title: sample_status
    )

    assert_not contact.valid?
    assert_predicate contact.errors[:confirm_policy], :present?
  end

  test "should accept contact when confirm_policy is true" do
    contact = ComContact.new(
      confirm_policy: "1",
      contact_category_title: sample_category,
      contact_status_title: sample_status
    )

    assert_predicate contact, :valid?
  end
end
