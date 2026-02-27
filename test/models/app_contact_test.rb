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
#  category_id      :bigint           not null
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
    contact.verify_email!

    assert_equal AppContactStatus::CHECKED_EMAIL_ADDRESS, contact.status_id
  end

  test "should verify phone" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_EMAIL_ADDRESS)

    assert_predicate contact, :can_verify_phone?
    contact.verify_phone!

    assert_equal AppContactStatus::CHECKED_TELEPHONE_NUMBER, contact.status_id
  end

  test "should complete contact" do
    contact = build_contact(status_id: AppContactStatus::CHECKED_TELEPHONE_NUMBER)

    assert_predicate contact, :can_complete?
    contact.complete!

    assert_equal AppContactStatus::COMPLETED_CONTACT_ACTION, contact.status_id
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
end
