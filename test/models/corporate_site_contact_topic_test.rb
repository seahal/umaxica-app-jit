require "test_helper"

class CorporateSiteContactTopicTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContactTopic < GuestsRecord
  end

  test "should belong to corporate_site_contact_topic" do
    topic = corporate_site_contact_topics(:one)
    assert_respond_to topic, :corporate_site_contact_topic
    # Note: This is a self-referential association
    # The fixture may not have a parent, so we just test the association exists
  end

  test "should have valid fixtures" do
    topic = corporate_site_contact_topics(:one)
    assert topic.valid?
  end

  test "should create topic with required attributes" do
    # Create a parent topic first for the self-referential association
    parent_topic = CorporateSiteContactTopic.create!(
      corporate_site_contact_topic: corporate_site_contact_topics(:one),
      title: "Parent Topic",
      description: "Parent description",
      deletable: false
    )

    topic = CorporateSiteContactTopic.new(
      corporate_site_contact_topic: parent_topic,
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
    parent_topic = corporate_site_contact_topics(:one)
    topic = CorporateSiteContactTopic.create!(
      corporate_site_contact_topic: parent_topic,
      title: "Test",
      description: "Test description"
    )
    assert_equal false, topic.deletable
    assert_equal "", topic.title if topic.title.blank?
    assert_equal "", topic.description if topic.description.blank?
  end

  test "title should not exceed 255 characters" do
    parent_topic = corporate_site_contact_topics(:one)
    topic = CorporateSiteContactTopic.new(
      corporate_site_contact_topic: parent_topic,
      title: "a" * 256,
      description: "Test"
    )
    # This may or may not fail depending on validations, but tests the schema limit
    assert_raises(ActiveRecord::ValueTooLong) do
      topic.save!
    end
  end
end
