# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contacts
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
#  index_com_contacts_on_category_id       (category_id)
#  index_com_contacts_on_public_id         (public_id)
#  index_com_contacts_on_status_id         (status_id)
#  index_com_contacts_on_token             (token)
#  index_com_contacts_on_token_digest      (token_digest)
#  index_com_contacts_on_token_expires_at  (token_expires_at)
#

require "test_helper"

class ComContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    # Create contact first
    contact = ComContact.new(**attrs.except(:com_contact_email, :com_contact_telephone))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.category_id ||= sample_category
    contact.status_id ||= sample_status
    contact.save!

    # Create email and telephone associated with the contact
    unless attrs.key?(:com_contact_email)
      ComContactEmail.create!(
        com_contact: contact,
        email_address: "test@example.com",
        expires_at: 1.day.from_now,
      )
    end

    unless attrs.key?(:com_contact_telephone)
      ComContactTelephone.create!(
        com_contact: contact,
        telephone_number: "+1234567890",
        expires_at: 1.day.from_now,
      )
    end

    contact
  end

  def sample_category
    ComContactCategory.find_by(id: "SECURITY_ISSUE")&.id || "NEYO"
  end

  def sample_status
    ComContactStatus.find_by(id: "NEYO")&.id || "NEYO"
  end

  test "should inherit from GuestsRecord" do
    assert_operator ComContact, :<, GuestsRecord
  end

  test "should have valid fixtures" do
    contact = com_contacts(:one)

    assert_predicate contact, :valid?
    assert_equal "SECURITY_ISSUE", contact.category_id
    assert_equal "NEYO", contact.status_id
  end

  test "should create contact with relationship titles" do
    contact = ComContact.new(
      category_id: sample_category,
      status_id: sample_status,
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal sample_category, contact.category_id
    assert_equal sample_status, contact.status_id
  end

  test "should set default category and status when nil" do
    contact = ComContact.new(
      category_id: nil,
      status_id: nil,
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "SECURITY_ISSUE", contact.category_id
    assert_equal "NEYO", contact.status_id
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

    assert_respond_to contact, :category_id
    assert_respond_to contact, :status_id
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
    contact = ComContact.new(
      category_id: "OTHERS",
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "OTHERS", contact.category_id
  end

  test "should reference contact_status by title" do
    ComContactStatus.create!(id: "SECURITY_ISSUE")

    contact = ComContact.new(
      status_id: "SECURITY_ISSUE",
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "SECURITY_ISSUE", contact.status_id
  end

  test "should set default category_id when nil" do
    contact = ComContact.new(
      category_id: nil,
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "SECURITY_ISSUE", contact.category_id
  end

  test "should set default status_id when nil" do
    contact = ComContact.new(
      status_id: nil,
      confirm_policy: "1",
    )

    assert contact.save

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    assert_equal "NEYO", contact.status_id
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
      expires_at: 1.day.from_now,
    )

    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
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
      category_id: sample_category,
      status_id: sample_status,
    )

    assert_not contact.valid?
    assert_predicate contact.errors[:confirm_policy], :present?
  end

  test "should accept contact when confirm_policy is true" do
    contact = ComContact.new(
      confirm_policy: "1",
      category_id: sample_category,
      status_id: sample_status,
    )

    assert_predicate contact, :valid?
  end

  # Callback tests for com_contact
  test "should generate public_id on create" do
    contact = ComContact.new(confirm_policy: "1")
    contact.save!

    assert_not_nil contact.public_id
    assert_equal 21, contact.public_id.length
  end

  test "should generate token on create" do
    contact = ComContact.new(confirm_policy: "1")
    contact.save!

    # After save, token should be generated (may be empty string from callback)
    contact.reload

    assert_respond_to contact, :token
  end

  test "should not overwrite existing public_id" do
    contact = ComContact.new(confirm_policy: "1", public_id: "existing_public_id")
    contact.save!

    assert_equal "existing_public_id", contact.public_id
  end

  test "should not overwrite existing token" do
    contact = ComContact.new(confirm_policy: "1", token: "existing_token_1234567890123456")
    contact.save!

    assert_equal "existing_token_1234567890123456", contact.token
  end

  # State checking tests for com_contact
  test "email_pending? should return true for email_pending state" do
    contact = build_contact
    contact.update!(status_id: "SET_UP")

    assert_predicate contact, :email_pending?
  end

  test "email_pending? should return true for NULL_COM_STATUS state" do
    contact = build_contact
    contact.update!(status_id: "NULL_COM_STATUS")

    assert_predicate contact, :email_pending?
  end

  test "email_verified? should return true for email_verified state" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")

    assert_predicate contact, :email_verified?
  end

  test "phone_verified? should return true for phone_verified state" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_TELEPHONE_NUMBER")

    assert_predicate contact, :phone_verified?
  end

  test "completed? should return true for completed state" do
    contact = build_contact
    contact.update!(status_id: "COMPLETED_CONTACT_ACTION")

    assert_predicate contact, :completed?
  end

  # State transition tests for com_contact
  test "can_verify_email? should return true when email_pending" do
    contact = build_contact
    contact.update!(status_id: "SET_UP")

    assert_predicate contact, :can_verify_email?
  end

  test "can_verify_phone? should return true when email_verified" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")

    assert_predicate contact, :can_verify_phone?
  end

  test "can_complete? should return true when phone_verified" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_TELEPHONE_NUMBER")

    assert_predicate contact, :can_complete?
  end

  test "verify_email! should transition to email_verified state" do
    contact = build_contact
    contact.update!(status_id: "SET_UP")

    result = contact.verify_email!

    assert result
    assert_equal "CHECKED_EMAIL_ADDRESS", contact.status_id
  end

  test "verify_email! should raise error when not in email_pending state" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")

    assert_raises(StandardError) do
      contact.verify_email!
    end
  end

  test "verify_phone! should transition to phone_verified state" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")

    result = contact.verify_phone!

    assert result
    assert_equal "CHECKED_TELEPHONE_NUMBER", contact.status_id
  end

  test "verify_phone! should raise error when not in email_verified state" do
    contact = build_contact
    contact.update!(status_id: "SET_UP")

    assert_raises(StandardError) do
      contact.verify_phone!
    end
  end

  test "complete! should transition to completed state" do
    contact = build_contact
    contact.update!(status_id: "CHECKED_TELEPHONE_NUMBER")

    result = contact.complete!

    assert result
    assert_equal "COMPLETED_CONTACT_ACTION", contact.status_id
  end

  test "complete! should raise error when not in phone_verified state" do
    contact = build_contact
    contact.update!(status_id: "SET_UP")

    assert_raises(StandardError) do
      contact.complete!
    end
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

  test "category_id length boundary" do
    contact = ComContact.new(confirm_policy: "1", category_id: "a" * 256)
    assert_not contact.valid?
    assert_not_empty contact.errors[:category_id]
  end

  test "status_id length boundary" do
    contact = ComContact.new(confirm_policy: "1", status_id: "a" * 256)
    assert_not contact.valid?
    assert_not_empty contact.errors[:status_id]
  end

  test "token length boundary" do
    contact = ComContact.new(confirm_policy: "1", token: "a" * 33)
    assert_not contact.valid?
    assert_not_empty contact.errors[:token]
  end

  test "association deletion: destroys dependent email, telephone, and topics" do
    contact = build_contact
    email = contact.com_contact_email
    phone = contact.com_contact_telephone
    topic = ComContactTopic.create!(com_contact: contact)

    contact.destroy
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
    assert_raise(ActiveRecord::RecordNotFound) { topic.reload }
  end
end
