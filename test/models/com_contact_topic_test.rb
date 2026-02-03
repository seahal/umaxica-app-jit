# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_topics
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
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  com_contact_id    :bigint           not null
#  public_id         :string(21)       not null
#
# Indexes
#
#  index_com_contact_topics_on_com_contact_id  (com_contact_id)
#  index_com_contact_topics_on_expires_at      (expires_at)
#  index_com_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

require "test_helper"

class ComContactTopicTest < ActiveSupport::TestCase
  fixtures :com_contact_categories, :com_contact_statuses

  test "should inherit from GuestRecord" do
    assert_operator ComContactTopic, :<, GuestRecord
  end

  def build_contact
    ComContactCategory.find_or_create_by!(id: ComContactCategory::NEYO)
    ComContactStatus.find_or_create_by!(id: ComContactStatus::NEYO)
    contact = ComContact.new(confirm_policy: "1")
    contact.category_id = ComContactCategory::NEYO
    contact.status_id = ComContactStatus::NEYO
    contact.save!

    ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now,
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
      deletable: false,
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use bigint as primary key" do
    contact = build_contact
    topic = ComContactTopic.create!(com_contact: contact)

    assert_kind_of Integer, topic.id
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
