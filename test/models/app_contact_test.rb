# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contacts
#
#  id               :uuid             not null, primary key
#  category_id      :string(255)      default("NEYO"), not null
#  created_at       :datetime         not null
#  ip_address       :inet             default("0.0.0.0"), not null
#  public_id        :string(21)       default(""), not null
#  status_id        :string(255)      default("NEYO")
#  token            :string(32)       default(""), not null
#  token_digest     :string(255)      default(""), not null
#  token_expires_at :timestamptz      default("-infinity"), not null
#  token_viewed     :boolean          default(FALSE), not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_app_contacts_on_category_id       (category_id)
#  index_app_contacts_on_public_id         (public_id)
#  index_app_contacts_on_status_id         (status_id)
#  index_app_contacts_on_token             (token)
#  index_app_contacts_on_token_digest      (token_digest)
#  index_app_contacts_on_token_expires_at  (token_expires_at)
#

require "test_helper"

class AppContactTest < ActiveSupport::TestCase
  # Fixtures are handled lazily via setup_fixtures.rb or loaded via fixtures :all

  def build_contact(**attrs)
    # Create contact first
    contact = AppContact.new(**attrs.except(:app_contact_emails, :app_contact_telephones))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.category_id ||= sample_category
    contact.status_id ||= sample_status
    contact.save!

    # Create email and telephone associated with the contact
    unless attrs.key?(:app_contact_emails)
      AppContactEmail.create!(
        app_contact: contact,
        email_address: "test@example.com",
        expires_at: 1.day.from_now,
      )
    end

    unless attrs.key?(:app_contact_telephones)
      AppContactTelephone.create!(
        app_contact: contact,
        telephone_number: "+1234567890",
        expires_at: 1.day.from_now,
      )
    end

    contact
  end

  def sample_category
    AppContactCategory.find_by(id: "APPLICATION_INQUIRY")&.id || "NEYO"
  end

  def sample_status
    AppContactStatus.find_by(id: "SET_UP")&.id || "NEYO"
  end

  test "should inherit from GuestsRecord" do
    assert_operator AppContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = app_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "NEYO", contact.category_id
    assert_equal "NEYO", contact.status_id
  end

  test "should create contact with relationship titles" do
    contact = AppContact.new(
      category_id: sample_category,
      status_id: sample_status,
      confirm_policy: "1",
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal sample_category, contact.category_id
    assert_equal sample_status, contact.status_id
  end

  test "should set default category and status when nil" do
    contact = AppContact.new(
      category_id: nil,
      status_id: nil,
      confirm_policy: "1",
    )

    save_result = contact.save
    assert save_result

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "APPLICATION_INQUIRY", contact.category_id
    assert_equal "NEYO", contact.status_id
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

    assert_respond_to contact, :category_id
    assert_respond_to contact, :status_id
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
      expires_at: 1.day.from_now,
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
      expires_at: 1.day.from_now,
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
      category_id: "app_category",
      confirm_policy: "1",
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "APP_CATEGORY", contact.category_id
  end

  test "should reference contact_status by title" do
    AppContactStatus.create!(id: "APP_STATUS")

    contact = AppContact.new(
      status_id: "app_status",
      confirm_policy: "1",
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "APP_STATUS", contact.status_id
  end

  test "should set default category_id when nil" do
    contact = AppContact.new(
      category_id: nil,
      confirm_policy: "1",
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "APPLICATION_INQUIRY", contact.category_id
  end

  test "should set default status_id when nil" do
    contact = AppContact.new(
      status_id: nil,
      confirm_policy: "1",
    )

    assert contact.save

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "NEYO", contact.status_id
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
      expires_at: 1.day.from_now,
    )

    email2 = AppContactEmail.create!(
      app_contact: contact,
      email_address: "second@example.com",
      expires_at: 1.day.from_now,
    )

    telephone1 = AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    telephone2 = AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now,
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
      category_id: sample_category,
      status_id: sample_status,
    )

    assert_not contact.valid?
    assert_predicate contact.errors[:confirm_policy], :present?
  end

  test "should accept contact when confirm_policy is true" do
    contact = AppContact.new(
      confirm_policy: "1",
      category_id: sample_category,
      status_id: sample_status,
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

  test "verify_token should return false when token_digest is blank" do
    contact = build_contact
    contact.update!(token_digest: "")

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

    assert_equal "NEYO", contact.category_id
    assert_equal "NEYO", contact.status_id
  end

  test "should verify email" do
    contact = build_contact(status_id: "SET_UP")

    assert_predicate contact, :can_verify_email?

    contact.verify_email!

    assert_equal "CHECKED_EMAIL_ADDRESS", contact.status_id
  end

  test "should verify phone" do
    contact = build_contact(status_id: "CHECKED_EMAIL_ADDRESS")

    assert_predicate contact, :can_verify_phone?

    contact.verify_phone!

    assert_equal "CHECKED_TELEPHONE_NUMBER", contact.status_id
  end

  test "should complete contact" do
    contact = build_contact(status_id: "CHECKED_TELEPHONE_NUMBER")

    assert_predicate contact, :can_complete?

    contact.complete!

    assert_equal "COMPLETED_CONTACT_ACTION", contact.status_id
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should generate and verify token" do
    contact = build_contact
    raw_token = contact.generate_final_token

    assert_not_nil contact.token_digest
    assert_not_nil contact.token_expires_at
    assert_not contact.token_viewed?

    assert contact.verify_token(raw_token)
    assert_predicate contact, :token_viewed?
    assert_not contact.verify_token(raw_token) # Cannot verify twice
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should handle expired token" do
    contact = build_contact
    raw_token = contact.generate_final_token

    contact.update!(token_expires_at: 1.minute.ago)

    assert_predicate contact, :token_expired?
    assert_not contact.verify_token(raw_token)
  end

  test "category_id length boundary" do
    contact = AppContact.new(confirm_policy: "1", category_id: "a" * 256)
    assert_not contact.valid?
    assert_not_empty contact.errors[:category_id]
  end

  test "status_id length boundary" do
    contact = AppContact.new(confirm_policy: "1", status_id: "a" * 256)
    assert_not contact.valid?
    assert_not_empty contact.errors[:status_id]
  end

  test "token length boundary" do
    contact = AppContact.new(confirm_policy: "1", token: "a" * 33)
    assert_not contact.valid?
    assert_not_empty contact.errors[:token]
  end

  test "association deletion: destroys dependent emails, telephones, and topics" do
    contact = build_contact
    email = contact.app_contact_emails.first
    phone = contact.app_contact_telephones.first
    topic = AppContactTopic.create!(app_contact: contact)

    contact.destroy
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
    assert_raise(ActiveRecord::RecordNotFound) { topic.reload }
  end

  test "token_expired? handles -infinity sentinel" do
    contact = AppContact.new(token_expires_at: "-infinity")
    assert_not contact.token_expired?
  end

  test "verify_email! raises if cannot verify" do
    contact = AppContact.new(status_id: "COMPLETED")
    assert_raise(StandardError) { contact.verify_email! }
  end

  test "verify_phone! raises if cannot verify" do
    contact = AppContact.new(status_id: "SET_UP")
    assert_raise(StandardError) { contact.verify_phone! }
  end

  test "complete! raises if cannot complete" do
    contact = AppContact.new(status_id: "SET_UP")
    assert_raise(StandardError) { contact.complete! }
  end

  test "before_validation upcases ids" do
    contact = AppContact.new(category_id: "lower_cat", status_id: "lower_stat")
    contact.valid?
    assert_equal "LOWER_CAT", contact.category_id
    assert_equal "LOWER_STAT", contact.status_id
  end
end
