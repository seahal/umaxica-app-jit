# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_topics
# Database name: guest
#
#  id             :bigint           not null, primary key
#  description    :text
#  title          :string(80)       default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  org_contact_id :bigint           not null
#  public_id      :string(21)       not null
#
# Indexes
#
#  index_org_contact_topics_on_org_contact_id  (org_contact_id)
#  index_org_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#
require "test_helper"

class OrgContactTopicTest < ActiveSupport::TestCase
  fixtures :org_contact_categories, :org_contact_statuses

  def build_topic(contact)
    OrgContactTopic.create!(
      org_contact: contact,
      title: "Test title",
      description: "Test body",
    )
  end

  test "should inherit from GuestRecord" do
    assert_operator OrgContactTopic, :<, GuestRecord
  end

  def build_contact
    contact = OrgContact.new
    contact.confirm_policy = "1"
    contact.category_id = OrgContactCategory::ORGANIZATION_INQUIRY
    contact.status_id = OrgContactStatus::NOTHING
    contact.save!

    OrgContactEmail.create!(
      org_contact: contact,
      email_address: "test@example.com",
    )

    OrgContactTelephone.create!(
      org_contact: contact,
      telephone_number: "+1234567890",
    )

    contact
  end

  test "should belong to org_contact" do
    contact = build_contact
    topic = build_topic(contact)

    assert_respond_to topic, :org_contact
    assert_not_nil topic.org_contact
  end

  test "should have valid minimal record" do
    contact = build_contact
    topic = build_topic(contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = build_contact

    topic = OrgContactTopic.new(
      org_contact: contact,
      title: "Test title",
      description: "Test body",
    )

    assert topic.save
  end

  test "should use bigint as primary key" do
    contact = build_contact
    topic = build_topic(contact)

    assert_kind_of Integer, topic.id
  end

  test "should have timestamps" do
    contact = build_contact
    topic = build_topic(contact)

    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end

  test "title length boundary" do
    contact = build_contact
    topic = OrgContactTopic.new(org_contact: contact, title: "a" * 80, description: "ok")

    assert_predicate topic, :valid?

    topic.title = "a" * 81

    assert_not topic.valid?
    assert_not_empty topic.errors[:title]
  end

  test "description length boundary" do
    contact = build_contact
    topic = OrgContactTopic.new(org_contact: contact, title: "ok", description: "a" * 8000)

    assert_predicate topic, :valid?

    topic.description = "a" * 8001

    assert_not topic.valid?
    assert_not_empty topic.errors[:description]
  end
end
