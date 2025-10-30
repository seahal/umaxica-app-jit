require "test_helper"

class CorporateSiteContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator CorporateSiteContactTopic, :<, GuestsRecord
  end

  test "should belong to corporate_site_contact" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_respond_to topic, :corporate_site_contact
    assert_not_nil topic.corporate_site_contact
  end

  test "should have valid minimal record" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_predicate topic, :valid?
  end

  test "should create topic with required attributes" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)

    topic = CorporateSiteContactTopic.new(
      corporate_site_contact: contact,
      deletable: false
    )

    assert topic.save
    assert_not topic.deletable
  end

  test "should use UUID as primary key" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_kind_of String, topic.id
    assert_equal 36, topic.id.length
  end

  test "should have timestamps" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end

  test "should have all expected attributes" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = CorporateSiteContact.create!(category: :general, status: :email_pending)
    topic = CorporateSiteContactTopic.create!(corporate_site_contact: contact)

    assert_not topic.deletable
  end
end
