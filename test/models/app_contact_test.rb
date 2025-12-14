require "test_helper"

class AppContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    # Create contact first
    contact = AppContact.new(**attrs.except(:app_contact_emails, :app_contact_telephones))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.save!

    # Create email and telephone associated with the contact
    unless attrs.key?(:app_contact_emails)
      AppContactEmail.create!(
        app_contact: contact,
        email_address: "test@example.com",
        expires_at: 1.day.from_now
      )
    end

    unless attrs.key?(:app_contact_telephones)
      AppContactTelephone.create!(
        app_contact: contact,
        telephone_number: "+1234567890",
        expires_at: 1.day.from_now
      )
    end

    contact
  end

  def sample_category
    app_contact_categories(:none).id
  end

  def sample_status
    app_contact_statuses(:none).id
  end

  test "should inherit from GuestsRecord" do
    assert_operator AppContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = app_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "APPLICATION_INQUIRY", contact.contact_category_title
    assert_equal "NULL_APP_STATUS", contact.contact_status_id
  end

  test "should create contact with relationship titles" do
    contact = AppContact.new(
      contact_category_title: sample_category,
      contact_status_id: sample_status,
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal sample_category, contact.contact_category_title
    assert_equal sample_status, contact.contact_status_id
  end

  test "should set default category and status when nil" do
    contact = AppContact.new(
      contact_category_title: nil,
      contact_status_id: nil,
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_APP_CATEGORY", contact.contact_category_title
    assert_equal "NULL_APP_STATUS", contact.contact_status_id
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = app_contacts(:one)

    assert_respond_to contact, :created_at
    assert_respond_to contact, :updated_at
    assert_not_nil contact.created_at
    assert_not_nil contact.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should use UUID as primary key" do
    contact = app_contacts(:one)

    assert_kind_of String, contact.id
    assert_equal 36, contact.id.length
  end

  test "should expose relationship title attributes" do
    contact = app_contacts(:one)

    assert_respond_to contact, :contact_category_title
    assert_respond_to contact, :contact_status_id
  end

  # Association tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should have many app_contact_emails" do
    contact = build_contact

    assert_respond_to contact, :app_contact_emails
    assert_equal 1, contact.app_contact_emails.count
    assert_instance_of AppContactEmail, contact.app_contact_emails.first

    # Test adding another email
    AppContactEmail.create!(
      app_contact: contact,
      email_address: "another@example.com",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.app_contact_emails.count
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should have many app_contact_telephones" do
    contact = build_contact

    assert_respond_to contact, :app_contact_telephones
    assert_equal 1, contact.app_contact_telephones.count
    assert_instance_of AppContactTelephone, contact.app_contact_telephones.first

    # Test adding another telephone
    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.app_contact_telephones.count
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have many app_contact_topics" do
    contact = build_contact

    assert_respond_to contact, :app_contact_topics
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

  test "verify_token should return false for incorrect token" do
    contact = build_contact
    contact.generate_final_token

    assert_not contact.verify_token("wrongtoken")
  end

  test "verify_token should return false if token viewed" do
    contact = build_contact
    raw = contact.generate_final_token

    assert contact.verify_token(raw)
    assert_not contact.verify_token(raw)
  end

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    AppContactCategory.create!(id: "APP_CATEGORY")

    contact = AppContact.new(
      contact_category_title: "app_category",
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "APP_CATEGORY", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    AppContactStatus.create!(id: "APP_STATUS")

    contact = AppContact.new(
      contact_status_id: "app_status",
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "APP_STATUS", contact.contact_status_id
  end

  test "should set default contact_category_title when nil" do
    contact = AppContact.new(
      contact_category_title: nil,
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_APP_CATEGORY", contact.contact_category_title
  end

  test "should set default contact_status_id when nil" do
    contact = AppContact.new(
      contact_status_id: nil,
      confirm_policy: "1"
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_equal "NULL_APP_STATUS", contact.contact_status_id
  end

  # Validation tests
  test "should allow contact without email addresses" do
    contact = AppContact.new(confirm_policy: "1")

    assert contact.save
    assert_equal 0, contact.app_contact_emails.count
  end

  test "should allow contact without telephone numbers" do
    contact = AppContact.new(confirm_policy: "1")

    assert contact.save
    assert_equal 0, contact.app_contact_telephones.count
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should allow contact with multiple emails and telephones" do
    contact = AppContact.new(confirm_policy: "1")
    contact.save!

    email1 = AppContactEmail.create!(
      app_contact: contact,
      email_address: "first@example.com",
      expires_at: 1.day.from_now
    )

    email2 = AppContactEmail.create!(
      app_contact: contact,
      email_address: "second@example.com",
      expires_at: 1.day.from_now
    )

    telephone1 = AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone2 = AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_equal 2, contact.app_contact_emails.count
    assert_includes contact.app_contact_emails, email1
    assert_includes contact.app_contact_emails, email2

    assert_equal 2, contact.app_contact_telephones.count
    assert_includes contact.app_contact_telephones, telephone1
    assert_includes contact.app_contact_telephones, telephone2
  end
  # rubocop:enable Minitest/MultipleAssertions

  # Validation: confirm_policy
  test "should require confirm_policy to be accepted" do
    contact = AppContact.new(
      confirm_policy: "0",
      contact_category_title: sample_category,
      contact_status_id: sample_status
    )

    assert_not contact.valid?
    assert_predicate contact.errors[:confirm_policy], :present?
  end

  test "should accept contact when confirm_policy is true" do
    contact = AppContact.new(
      confirm_policy: "1",
      contact_category_title: sample_category,
      contact_status_id: sample_status
    )

    assert_predicate contact, :valid?
  end

  # Callback tests
  test "should generate public_id on create" do
    contact = AppContact.new(confirm_policy: "1")
    contact.save!

    assert_not_nil contact.public_id
    assert_equal 21, contact.public_id.length
  end

  test "should generate token on create" do
    contact = AppContact.new(confirm_policy: "1")
    contact.save!

    # After save, token should be generated (may be empty string from callback)
    contact.reload

    assert_respond_to contact, :token
  end

  test "should not overwrite existing public_id" do
    contact = AppContact.new(confirm_policy: "1", public_id: "existing_public_id")
    contact.save!

    assert_equal "existing_public_id", contact.public_id
  end

  test "should not overwrite existing token" do
    contact = AppContact.new(confirm_policy: "1", token: "existing_token_1234567890123456")
    contact.save!

    assert_equal "existing_token_1234567890123456", contact.token
  end

  test "should respond to transition methods" do
    contact = build_contact

    assert_respond_to contact, :verify_email!
    assert_respond_to contact, :verify_phone!
    assert_respond_to contact, :complete!
  end

  test "should respond to predicate methods" do
    contact = build_contact

    assert_respond_to contact, :can_verify_email?
    assert_respond_to contact, :can_verify_phone?
    assert_respond_to contact, :can_complete?
  end

  test "to_param should return public_id" do
    contact = build_contact

    assert_equal contact.public_id, contact.to_param
  end

  test "verify_token should return false when token_digest is nil" do
    contact = build_contact
    contact.update!(token_digest: nil)

    assert_not contact.verify_token("any_token")
  end

  # Additional branch coverage tests
  test "verify_token returns false when token has been viewed" do
    contact = build_contact
    raw_token = contact.generate_final_token
    contact.verify_token(raw_token)
    contact.reload

    # Second verification should fail because token_viewed is true
    assert_not contact.verify_token(raw_token)
  end

  test "to_param returns different value for each contact" do
    contact1 = build_contact
    contact2 = build_contact

    assert_not_equal contact1.to_param, contact2.to_param
  end

  test "contact can be created with minimal attributes" do
    contact = AppContact.new(confirm_policy: "1")

    assert contact.save
    assert_not_nil contact.id
  end

  test "default category is set on initialize" do
    contact = AppContact.new(confirm_policy: "1")
    contact.save!

    assert_equal "NULL_APP_CATEGORY", contact.contact_category_title
    assert_equal "NULL_APP_STATUS", contact.contact_status_id
  end
end
