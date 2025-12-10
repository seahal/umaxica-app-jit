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
      expires_at: 1.day.from_now
    )

    OrgContactTelephone.create!(
      org_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
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
      deletable: false
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
