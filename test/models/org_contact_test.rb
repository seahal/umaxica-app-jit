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
#  category_id      :bigint           not null
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
      OrgContactStatus::NEYO,
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
      OrgContactCategory::NEYO,
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
    assert_equal OrgContactStatus::NEYO, contact.status_id
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
    contact.verify_email!

    assert_equal OrgContactStatus::CHECKED_EMAIL_ADDRESS, contact.status_id
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
end
