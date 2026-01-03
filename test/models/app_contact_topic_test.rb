# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_topics
#
#  id                :uuid             not null, primary key
#  app_contact_id    :uuid             not null
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  remaining_views   :integer          default(0), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  otp_attempts_left :integer          default(0), not null
#  expires_at        :timestamptz      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  public_id         :string(21)       default(""), not null
#
# Indexes
#
#  index_app_contact_topics_on_app_contact_id  (app_contact_id)
#  index_app_contact_topics_on_expires_at      (expires_at)
#  index_app_contact_topics_on_public_id       (public_id)
#

require "test_helper"

class AppContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestRecord" do
    assert_operator AppContactTopic, :<, GuestRecord
  end

  def build_contact
    contact = AppContact.new
    contact.confirm_policy = "1"
    contact.category_id = "NEYO"
    contact.status_id = "NEYO"
    contact.save!

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

    contact
  end

  test "should belong to app_contact" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_respond_to topic, :app_contact
    assert_not_nil topic.app_contact
  end

  test "should have valid minimal record" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = build_contact

    topic = AppContactTopic.new(
      app_contact: contact,
      deletable: false,
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use UUID as primary key" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_kind_of String, topic.id
    assert_equal 36, topic.id.length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have all expected attributes" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = build_contact
    topic = AppContactTopic.create!(app_contact: contact)

    assert_not topic.deletable
  end
end
