# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contacts
# Database name: guest
#
#  id               :bigint           not null, primary key
#  ip_address       :inet
#  token            :string(32)       default(""), not null
#  token_digest     :string
#  token_expires_at :datetime
#  token_viewed     :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :bigint           default(0), not null
#  public_id        :string(21)       not null
#  status_id        :bigint           not null
#
# Indexes
#
#  index_app_contacts_on_category_id       (category_id)
#  index_app_contacts_on_public_id         (public_id) UNIQUE
#  index_app_contacts_on_status_id         (status_id)
#  index_app_contacts_on_token             (token)
#  index_app_contacts_on_token_digest      (token_digest)
#  index_app_contacts_on_token_expires_at  (token_expires_at)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => app_contact_categories.id)
#  fk_rails_...  (status_id => app_contact_statuses.id) ON DELETE => restrict
#
require "test_helper"

class AppContactTest < ActiveSupport::TestCase
  def build_contact(**attrs)
    contact_attrs = attrs.except(:app_contact_emails, :app_contact_telephones)
    unless contact_attrs[:category_id]
      contact_attrs[:app_contact_category] = AppContactCategory.find(sample_category)
    end
    unless contact_attrs[:status_id]
      contact_attrs[:app_contact_status] = AppContactStatus.find(sample_status)
    end

    contact = AppContact.new(**contact_attrs)
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.save!

    unless attrs.key?(:app_contact_emails)
      AppContactEmail.create!(
        app_contact: contact,
        email_address: "test@example.com",
      )
    end

    unless attrs.key?(:app_contact_telephones)
      AppContactTelephone.create!(
        app_contact: contact,
        telephone_number: "+1234567890",
      )
    end

    contact
  end

  setup do
    create_all_statuses
    create_all_categories
  end

  def sample_category
    AppContactCategory::APPLICATION_INQUIRY
  end

  def sample_status
    AppContactStatus::SET_UP
  end

  def create_all_statuses
    statuses = [
      AppContactStatus::NOTHING,
      AppContactStatus::SET_UP,
      AppContactStatus::CHECKED_EMAIL_ADDRESS,
      AppContactStatus::CHECKED_TELEPHONE_NUMBER,
      AppContactStatus::COMPLETED_CONTACT_ACTION,
    ]
    statuses.each do |id|
      AppContactStatus.find_or_create_by!(id: id)
    end
  end

  def create_all_categories
    categories = [
      AppContactCategory::NOTHING,
      AppContactCategory::APPLICATION_INQUIRY,
    ]
    categories.each do |id|
      AppContactCategory.find_or_create_by!(id: id)
    end
  end

  test "should inherit from GuestRecord" do
    assert_operator AppContact, :<, GuestRecord
  end

  test "should have valid factory" do
    contact = build_contact

    assert_predicate contact, :valid?
    assert_equal AppContactCategory::APPLICATION_INQUIRY, contact.category_id
    assert_equal AppContactStatus::SET_UP, contact.status_id
  end

  test "should set default category and status when nil" do
    contact = AppContact.new(category_id: nil, status_id: nil, confirm_policy: "1")

    assert contact.save
    assert_equal AppContactCategory::APPLICATION_INQUIRY, contact.category_id
    assert_equal AppContactStatus::NOTHING, contact.status_id
  end

  test "should generate public_id on create" do
    contact = AppContact.new(confirm_policy: "1")
    contact.save!

    assert_not_nil contact.public_id
    assert_equal 21, contact.public_id.length
  end

  test "should respond to transition methods" do
    contact = build_contact

    assert_respond_to contact, :verify_email!
    assert_respond_to contact, :verify_phone!
    assert_respond_to contact, :complete!
  end

  test "should verify email" do
    contact = build_contact(status_id: AppContactStatus::SET_UP)

    assert_predicate contact, :can_verify_email?
    assert contact.verify_email!

    assert_equal AppContactStatus::CHECKED_EMAIL_ADDRESS, contact.status_id
  end

  test "should verify phone" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_EMAIL_ADDRESS)

    assert_predicate contact, :can_verify_phone?
    assert contact.verify_phone!

    assert_equal AppContactStatus::CHECKED_TELEPHONE_NUMBER, contact.status_id
  end

  test "should complete contact" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert_predicate contact, :can_complete?
    assert contact.complete!

    assert_equal AppContactStatus::COMPLETED_CONTACT_ACTION, contact.status_id
  end

  test "should add errors instead of raising on invalid transitions" do
    contact = build_contact(status_id: AppContactStatus::NOTHING)

    assert_not contact.verify_email!
    assert_includes contact.errors[:base], "Cannot verify email at this time"

    contact.errors.clear

    assert_not contact.verify_phone!
    assert_includes contact.errors[:base], "Cannot verify phone at this time"

    contact.errors.clear

    assert_not contact.complete!
    assert_includes contact.errors[:base], "Cannot complete contact at this time"
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
    topic = AppContactTopic.create!(app_contact: contact, title: "Test title", description: "Test body")

    contact.destroy
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
    assert_raise(ActiveRecord::RecordNotFound) { topic.reload }
  end

  test "email_pending? returns true for SET_UP status" do
    contact = build_contact(status_id: AppContactStatus::SET_UP)

    assert_predicate contact, :email_pending?
  end

  test "email_pending? returns false for other statuses" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_EMAIL_ADDRESS)

    assert_not_predicate contact, :email_pending?
  end

  test "email_verified? returns true for CHECKED_EMAIL_ADDRESS" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_EMAIL_ADDRESS)

    assert_predicate contact, :email_verified?
  end

  test "email_verified? returns false for other statuses" do
    contact = build_contact(status_id: AppContactStatus::SET_UP)

    assert_not_predicate contact, :email_verified?
  end

  test "phone_verified? returns true for CHECKED_TELEPHONE_NUMBER" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert_predicate contact, :phone_verified?
  end

  test "phone_verified? returns false for other statuses" do
    contact = build_contact(status_id: AppContactStatus::SET_UP)

    assert_not_predicate contact, :phone_verified?
  end

  test "generate_final_token creates token digest and returns raw token" do
    contact = build_contact

    raw_token = contact.generate_final_token

    assert_not_nil contact.token_digest
    assert_not_nil contact.token_expires_at
    assert_equal 32, raw_token.length
  end

  test "verify_token returns true for valid token" do
    contact = build_contact
    raw_token = contact.generate_final_token

    assert contact.verify_token(raw_token)
    assert_predicate contact, :token_viewed?
  end

  test "verify_token returns false when already viewed" do
    contact = build_contact
    raw_token = contact.generate_final_token
    contact.verify_token(raw_token)

    assert_not contact.verify_token(raw_token)
  end

  test "verify_token returns false for invalid token" do
    contact = build_contact
    contact.generate_final_token

    assert_not contact.verify_token("invalid_token")
  end

  test "verify_token returns false for expired token" do
    contact = build_contact
    contact.update!(token_expires_at: 1.day.ago)

    assert_not contact.verify_token("any_token")
  end

  test "token_expired? returns true when expired" do
    contact = build_contact
    contact.update!(token_expires_at: 1.day.ago)

    assert_predicate contact, :token_expired?
  end

  test "token_expired? returns false when not expired" do
    contact = build_contact
    contact.update!(token_expires_at: 7.days.from_now)

    assert_not_predicate contact, :token_expired?
  end

  test "to_param returns public_id" do
    contact = build_contact

    assert_equal contact.public_id, contact.to_param
  end
end
