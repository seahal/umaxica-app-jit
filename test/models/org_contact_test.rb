# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contacts
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
#  index_org_contacts_on_category_id       (category_id)
#  index_org_contacts_on_public_id         (public_id) UNIQUE
#  index_org_contacts_on_status_id         (status_id)
#  index_org_contacts_on_token             (token)
#  index_org_contacts_on_token_digest      (token_digest)
#  index_org_contacts_on_token_expires_at  (token_expires_at)
#
# Foreign Keys
#
#  fk_org_contacts_on_status_id_nullify  (status_id => org_contact_statuses.id) ON DELETE => nullify
#  fk_rails_...                          (category_id => org_contact_categories.id)
#
require "test_helper"

class OrgContactTest < ActiveSupport::TestCase
  setup do
    create_all_statuses
    create_all_categories
  end

  def build_contact(**attrs)
    contact = OrgContact.new(**attrs.except(:org_contact_emails, :org_contact_telephones))
    contact.confirm_policy = "1" unless attrs.key?(:confirm_policy)
    contact.category_id ||= sample_category
    contact.status_id ||= sample_status
    contact.save!

    unless attrs.key?(:org_contact_emails)
      OrgContactEmail.create!(
        org_contact: contact,
        email_address: "test@example.com",
      )
    end

    unless attrs.key?(:org_contact_telephones)
      OrgContactTelephone.create!(
        org_contact: contact,
        telephone_number: "+1234567890",
      )
    end

    contact
  end

  def sample_category
    OrgContactCategory::ORGANIZATION_INQUIRY
  end

  def sample_status
    OrgContactStatus::SET_UP
  end

  def create_all_statuses
    statuses = [
      OrgContactStatus::NOTHING,
      OrgContactStatus::SET_UP,
      OrgContactStatus::CHECKED_EMAIL_ADDRESS,
      OrgContactStatus::CHECKED_TELEPHONE_NUMBER,
      OrgContactStatus::COMPLETED_CONTACT_ACTION,
    ]
    statuses.each do |id|
      OrgContactStatus.find_or_create_by!(id: id)
    end
  end

  def create_all_categories
    categories = [
      OrgContactCategory::NOTHING,
      OrgContactCategory::ORGANIZATION_INQUIRY,
    ]
    categories.each do |id|
      OrgContactCategory.find_or_create_by!(id: id)
    end
  end

  test "should inherit from GuestRecord" do
    assert_operator OrgContact, :<, GuestRecord
  end

  test "should set default category and status when nil" do
    contact = OrgContact.new(category_id: nil, status_id: nil, confirm_policy: "1")

    assert contact.save
    assert_equal OrgContactCategory::ORGANIZATION_INQUIRY, contact.category_id
    assert_equal OrgContactStatus::NOTHING, contact.status_id
  end

  test "should generate public_id on create" do
    contact = OrgContact.new(confirm_policy: "1")
    contact.save!

    assert_not_nil contact.public_id
    assert_equal 21, contact.public_id.length
  end

  test "should verify email" do
    contact = build_contact(status_id: OrgContactStatus::SET_UP)

    assert_predicate contact, :can_verify_email?
    assert contact.verify_email!

    assert_equal OrgContactStatus::CHECKED_EMAIL_ADDRESS, contact.status_id
  end

  test "should add errors instead of raising on invalid transition" do
    contact = build_contact(status_id: OrgContactStatus::NOTHING)

    assert_not contact.verify_email!
    assert_includes contact.errors[:base], "Cannot verify email at this time"
  end

  test "association deletion: destroys dependent emails, telephones, and topics" do
    contact = build_contact
    email = contact.org_contact_emails.first
    phone = contact.org_contact_telephones.first
    topic = OrgContactTopic.create!(org_contact: contact, title: "Test title", description: "Test body")

    contact.destroy
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
    assert_raise(ActiveRecord::RecordNotFound) { topic.reload }
  end

  test "phone_verified? returns true when status is CHECKED_TELEPHONE_NUMBER" do
    contact = build_contact(status_id: OrgContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert_predicate contact, :phone_verified?
  end

  test "phone_verified? returns false when status is not CHECKED_TELEPHONE_NUMBER" do
    contact = build_contact(status_id: OrgContactStatus::SET_UP)

    assert_not_predicate contact, :phone_verified?
  end

  test "can_verify_phone? returns true when email is verified" do
    contact = build_contact(status_id: OrgContactStatus::CHECKED_EMAIL_ADDRESS)

    assert_predicate contact, :can_verify_phone?
  end

  test "can_verify_phone? returns false when email is not verified" do
    contact = build_contact(status_id: OrgContactStatus::SET_UP)

    assert_not_predicate contact, :can_verify_phone?
  end

  test "verify_phone! transitions status to CHECKED_TELEPHONE_NUMBER" do
    contact = build_contact(status_id: OrgContactStatus::CHECKED_EMAIL_ADDRESS)

    assert contact.verify_phone!
    assert_equal OrgContactStatus::CHECKED_TELEPHONE_NUMBER, contact.status_id
  end

  test "verify_phone! adds error when cannot verify phone" do
    contact = build_contact(status_id: OrgContactStatus::NOTHING)

    assert_not contact.verify_phone!
    assert_includes contact.errors[:base], "Cannot verify phone at this time"
  end

  test "can_complete? returns true when phone is verified" do
    contact = build_contact(status_id: OrgContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert_predicate contact, :can_complete?
  end

  test "complete! transitions status to COMPLETED_CONTACT_ACTION" do
    contact = build_contact(status_id: OrgContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert contact.complete!
    assert_equal OrgContactStatus::COMPLETED_CONTACT_ACTION, contact.status_id
  end

  test "complete! adds error when cannot complete" do
    contact = build_contact(status_id: OrgContactStatus::SET_UP)

    assert_not contact.complete!
    assert_includes contact.errors[:base], "Cannot complete contact at this time"
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

  test "verify_token returns false when token already viewed" do
    contact = build_contact
    raw_token = contact.generate_final_token
    contact.verify_token(raw_token)

    assert_not contact.verify_token(raw_token)
  end

  test "verify_token returns false for expired token" do
    contact = build_contact
    contact.update!(token_expires_at: 1.day.ago)

    assert_not contact.verify_token("any_token")
  end

  test "verify_token returns false for invalid token" do
    contact = build_contact
    contact.generate_final_token

    assert_not contact.verify_token("invalid_token")
  end

  test "token_expired? returns true when token is expired" do
    contact = build_contact
    contact.update!(token_expires_at: 1.day.ago)

    assert_predicate contact, :token_expired?
  end

  test "token_expired? returns false when token is not expired" do
    contact = build_contact
    contact.update!(token_expires_at: 7.days.from_now)

    assert_not_predicate contact, :token_expired?
  end

  test "token_expired? returns false when token_expires_at is nil" do
    contact = build_contact
    contact.update!(token_expires_at: nil)

    assert_not_predicate contact, :token_expired?
  end

  test "to_param returns public_id" do
    contact = build_contact

    assert_equal contact.public_id, contact.to_param
  end
end
