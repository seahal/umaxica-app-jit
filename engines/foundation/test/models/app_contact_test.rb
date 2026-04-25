# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contacts
# Database name: guest
#
#  id          :bigint           not null, primary key
#  ip_address  :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           default(0), not null
#  public_id   :string(21)       not null
#  status_id   :bigint           not null
#
# Indexes
#
#  index_app_contacts_on_category_id  (category_id)
#  index_app_contacts_on_public_id    (public_id) UNIQUE
#  index_app_contacts_on_status_id    (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => app_contact_categories.id)
#  fk_rails_...  (status_id => app_contact_statuses.id) ON DELETE => restrict
#
require "test_helper"

class AppContactTest < ActiveSupport::TestCase
  fixtures :app_contact_categories, :app_contact_statuses

  def setup
    @category = app_contact_categories(:application_inquiry)
    @status = app_contact_statuses(:NOTHING)
  end

  def build_contact(**attrs)
    contact_attrs = {
      category_id: @category.id,
      status_id: @status.id,
      confirm_policy: "1",
    }.merge(attrs)

    contact = AppContact.new(**contact_attrs)
    contact.save!
    contact
  end

  test "should be valid with required attributes" do
    contact = build_contact

    assert_predicate contact, :valid?
  end

  test "should require confirm_policy acceptance" do
    contact = AppContact.new(
      category_id: @category.id,
      status_id: @status.id,
      confirm_policy: "0",
    )

    assert_not contact.valid?
    # Error message is localized, check for any error on confirm_policy
    assert_predicate contact.errors[:confirm_policy], :any?
  end

  test "should have unique public_id" do
    contact1 = build_contact
    contact2 = AppContact.new(
      category_id: @category.id,
      status_id: @status.id,
      confirm_policy: "1",
      public_id: contact1.public_id,
    )

    assert_not contact2.valid?
    # Error message is localized, check for any error on public_id
    assert_predicate contact2.errors[:public_id], :any?
  end

  test "should belong to category" do
    contact = build_contact

    assert_equal @category, contact.app_contact_category
  end

  test "should belong to status" do
    contact = build_contact

    assert_equal @status, contact.app_contact_status
  end

  test "should set default category on initialize" do
    contact = AppContact.new(confirm_policy: "1", status_id: @status.id)

    assert_equal AppContactCategory::APPLICATION_INQUIRY, contact.category_id
  end

  test "should set default status on initialize" do
    contact = AppContact.new(confirm_policy: "1", category_id: @category.id)

    assert_equal AppContactStatus::NOTHING, contact.status_id
  end

  test "should have many topics" do
    contact = build_contact
    topic = contact.app_contact_topics.create!(title: "Test Topic", description: "Test description")

    assert_includes contact.app_contact_topics, topic
  end

  test "should have many emails" do
    contact = build_contact
    email = contact.app_contact_emails.create!(email_address: "test@example.com")

    assert_includes contact.app_contact_emails, email
  end

  test "should have many telephones" do
    contact = build_contact
    phone = contact.app_contact_telephones.create!(telephone_number: "+819012345678")

    assert_includes contact.app_contact_telephones, phone
  end

  test "should use public_id in to_param" do
    contact = build_contact

    assert_equal contact.public_id, contact.to_param
  end

  test "should destroy dependent topics on destroy" do
    contact = build_contact
    _topic = contact.app_contact_topics.create!(title: "Test Topic", description: "Test description")

    assert_difference("AppContactTopic.count", -1) do
      contact.destroy
    end
  end

  test "should destroy dependent emails on destroy" do
    contact = build_contact
    _email = contact.app_contact_emails.create!(email_address: "test@example.com")

    assert_difference("AppContactEmail.count", -1) do
      contact.destroy
    end
  end

  test "should destroy dependent telephones on destroy" do
    contact = build_contact
    _phone = contact.app_contact_telephones.create!(telephone_number: "+819012345678")

    assert_difference("AppContactTelephone.count", -1) do
      contact.destroy
    end
  end
end
