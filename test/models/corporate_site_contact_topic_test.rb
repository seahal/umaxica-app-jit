require "test_helper"

class CorporateSiteContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContactTopic < GuestsRecord
  end

  test "should belong to corporate_site_contact" do
    topic = corporate_site_contact_topics(:one)
    assert_respond_to topic, :corporate_site_contact
    assert_not_nil topic.corporate_site_contact
  end

  test "should have valid fixtures" do
    topic = corporate_site_contact_topics(:one)
    assert topic.valid?
  end

  test "should create topic with required attributes" do
    contact = corporate_site_contacts(:one)

    topic = CorporateSiteContactTopic.new(
      corporate_site_contact: contact,
      title: "Test Topic",
      description: "Test description",
      deletable: false
    )
    assert topic.save
    assert_equal "Test Topic", topic.title
    assert_equal "Test description", topic.description
    assert_equal false, topic.deletable
  end

  test "should use UUID as primary key" do
    topic = corporate_site_contact_topics(:one)
    assert_kind_of String, topic.id
    assert_equal 36, topic.id.length
  end

  test "should have timestamps" do
    topic = corporate_site_contact_topics(:one)
    assert_respond_to topic, :created_at
    assert_respond_to topic, :updated_at
    assert_not_nil topic.created_at
    assert_not_nil topic.updated_at
  end

  test "should have all expected attributes" do
    topic = corporate_site_contact_topics(:one)
    assert_respond_to topic, :title
    assert_respond_to topic, :description
    assert_respond_to topic, :deletable
  end

  test "should have default values" do
    contact = corporate_site_contacts(:one)
    topic = CorporateSiteContactTopic.create!(
      corporate_site_contact: contact,
      title: "Test",
      description: "Test description"
    )
    assert_equal false, topic.deletable
    assert_equal "", topic.title if topic.title.blank?
    assert_equal "", topic.description if topic.description.blank?
  end

  test "title should not exceed 255 characters" do
    contact = corporate_site_contacts(:one)
    topic = CorporateSiteContactTopic.new(
      corporate_site_contact: contact,
      title: "a" * 256,
      description: "Test"
    )
    # Model validation will catch this before database constraint
    assert_raises(ActiveRecord::RecordInvalid) do
      topic.save!
    end
    assert_not topic.valid?
    assert topic.errors[:title].any?
  end
end
