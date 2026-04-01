# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_topics
# Database name: guest
#
#  id                :bigint           not null, primary key
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  description       :text
#  expires_at        :datetime         not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string
#  otp_expires_at    :datetime
#  remaining_views   :integer          default(10), not null
#  title             :string(80)       default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  app_contact_id    :bigint           not null
#  public_id         :string(21)       not null
#
# Indexes
#
#  index_app_contact_topics_on_app_contact_id  (app_contact_id)
#  index_app_contact_topics_on_expires_at      (expires_at)
#  index_app_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#

require "test_helper"

class AppContactTopicTest < ActiveSupport::TestCase
  fixtures :app_contact_categories, :app_contact_statuses

  def build_topic(contact)
    AppContactTopic.create!(
      app_contact: contact,
      title: "Test title",
      description: "Test body",
    )
  end

  test "should inherit from GuestRecord" do
    assert_operator AppContactTopic, :<, GuestRecord
  end

  def build_contact
    AppContactCategory.find_or_create_by!(id: AppContactCategory::NOTHING)
    AppContactStatus.find_or_create_by!(id: AppContactStatus::NOTHING)
    contact = AppContact.new
    contact.confirm_policy = "1"
    contact.category_id = AppContactCategory::NOTHING
    contact.status_id = AppContactStatus::NOTHING
    contact.save!

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
    )

    contact
  end

  test "should belong to app_contact" do
    contact = build_contact
    topic = build_topic(contact)

    assert_respond_to topic, :app_contact
    assert_not_nil topic.app_contact
  end

  test "should have valid minimal record" do
    contact = build_contact
    topic = build_topic(contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = build_contact

    topic = AppContactTopic.new(
      app_contact: contact,
      title: "Test title",
      description: "Test body",
      deletable: false,
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use numeric primary key" do
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

  test "should have all expected attributes" do
    contact = build_contact
    topic = build_topic(contact)

    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = build_contact
    topic = build_topic(contact)

    assert_not topic.deletable
  end

  test "title length boundary" do
    contact = build_contact
    topic = AppContactTopic.new(app_contact: contact, title: "a" * 80, description: "ok")

    assert_predicate topic, :valid?

    topic.title = "a" * 81

    assert_not topic.valid?
    assert_not_empty topic.errors[:title]
  end

  test "description length boundary" do
    contact = build_contact
    topic = AppContactTopic.new(app_contact: contact, title: "ok", description: "a" * 8000)

    assert_predicate topic, :valid?

    topic.description = "a" * 8001

    assert_not topic.valid?
    assert_not_empty topic.errors[:description]
  end
end
