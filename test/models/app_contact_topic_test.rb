require "test_helper"

class AppContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator AppContactTopic, :<, GuestsRecord
  end

  def build_contact
    contact = AppContact.new
    contact.confirm_policy = "1"
    contact.save!

    AppContactEmail.create!(
      app_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )

    AppContactTelephone.create!(
      app_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
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
      deletable: false
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
