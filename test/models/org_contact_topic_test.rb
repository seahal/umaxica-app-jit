# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_topics
#
#  id                :uuid             not null, primary key
#  activated         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  deletable         :boolean          default(FALSE), not null
#  expires_at        :timestamptz      not null
#  org_contact_id    :uuid             not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  public_id         :string(21)       default(""), not null
#  remaining_views   :integer          default(10), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_org_contact_topics_on_expires_at      (expires_at)
#  index_org_contact_topics_on_org_contact_id  (org_contact_id)
#  index_org_contact_topics_on_public_id       (public_id)
#

require "test_helper"

class OrgContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator OrgContactTopic, :<, GuestsRecord
  end

  def build_contact
    contact = OrgContact.new
    contact.confirm_policy = "1"
    contact.save!

    OrgContactEmail.create!(
      org_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    OrgContactTelephone.create!(
      org_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
    )

    contact
  end

  test "should belong to org_contact" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_respond_to topic, :org_contact
    assert_not_nil topic.org_contact
  end

  test "should have valid minimal record" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = build_contact

    topic = OrgContactTopic.new(
      org_contact: contact,
      deletable: false,
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use UUID as primary key" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_kind_of String, topic.id
    assert_equal 36, topic.id.length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have all expected attributes" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = build_contact
    topic = OrgContactTopic.create!(org_contact: contact)

    assert_not topic.deletable
  end
end
