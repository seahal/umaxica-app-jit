require "test_helper"


class ComContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    # Create email and telephone first with explicit IDs
    email = attrs[:com_contact_email] || ComContactEmail.create!(
      id: SecureRandom.uuid,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )
    telephone = attrs[:com_contact_telephone] || ComContactTelephone.create!(
      id: SecureRandom.uuid,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    # Create contact with references
    contact = ComContact.new(**attrs.except(:com_contact_email, :com_contact_telephone))
    contact.com_contact_email = email
    contact.com_contact_telephone = telephone
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.save!
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
    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_category_title: sample_category,
      contact_status_title: sample_status,
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
    assert_equal sample_category, contact.contact_category_title
    assert_equal sample_status, contact.contact_status_title
  end

  test "should set default category and status when nil" do
    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_category_title: nil,
      contact_status_title: nil,
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
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
  test "should belong to com_contact_email" do
    contact = build_contact

    assert_respond_to contact, :com_contact_email
    assert_instance_of ComContactEmail, contact.com_contact_email
  end

  test "should belong to com_contact_telephone" do
    contact = build_contact

    assert_respond_to contact, :com_contact_telephone
    assert_instance_of ComContactTelephone, contact.com_contact_telephone
  end

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

    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_category_title: "com_category",
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
    assert_equal "com_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    ComContactStatus.create!(title: "com_status")

    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_status_title: "com_status",
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
    assert_equal "com_status", contact.contact_status_title
  end

  test "should set default contact_category_title when nil" do
    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_category_title: nil,
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
    assert_equal "NULL_COM_CATEGORY", contact.contact_category_title
  end

  test "should set default contact_status_title when nil" do
    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      contact_status_title: nil,
      com_contact_email: email,
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert contact.save
    assert_equal "NULL_COM_STATUS", contact.contact_status_title
  end

  # Validation tests
  test "should require email" do
    telephone = ComContactTelephone.create!(id: SecureRandom.uuid, telephone_number: "+1234567890", expires_at: 1.day.from_now)

    contact = ComContact.new(
      com_contact_telephone: telephone,
      confirm_policy: "1"
    )

    assert_not contact.valid?
    assert_includes contact.errors[:com_contact_email], "を入力してください"
  end

  test "should require telephone" do
    email = ComContactEmail.create!(id: SecureRandom.uuid, email_address: "test@example.com", expires_at: 1.day.from_now)

    contact = ComContact.new(
      com_contact_email: email,
      confirm_policy: "1"
    )

    assert_not contact.valid?
    assert_includes contact.errors[:com_contact_telephone], "を入力してください"
  end
end
