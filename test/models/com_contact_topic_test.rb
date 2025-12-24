# == Schema Information
#
# Table name: com_contact_topics
#
#  id                :uuid             not null, primary key
#  activated         :boolean          default(FALSE), not null
#  com_contact_id    :uuid             not null
#  created_at        :datetime         not null
#  deletable         :boolean          default(FALSE), not null
#  description       :text             default(""), not null
#  expires_at        :timestamptz      not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  public_id         :string(21)       default(""), not null
#  remaining_views   :integer          default(10), not null
#  title             :string           default(""), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_com_contact_topics_on_com_contact_id  (com_contact_id)
#  index_com_contact_topics_on_expires_at      (expires_at)
#  index_com_contact_topics_on_public_id       (public_id)
#

require "test_helper"

class ComContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator ComContactTopic, :<, GuestsRecord
  end

  def build_contact
    contact = ComContact.new(confirm_policy: "1")
    contact.save!

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    contact
  end

  test "should belong to com_contact" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_respond_to topic, :com_contact
    assert_not_nil topic.com_contact
  end

  test "should have valid minimal record" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = build_contact

    topic = ComContactTopic.new(
      com_contact: contact,
      deletable: false
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use UUID as primary key" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_kind_of String, topic.id
    assert_equal 36, topic.id.length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have all expected attributes" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_not topic.deletable
  end
end
