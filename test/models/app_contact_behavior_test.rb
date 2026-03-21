# typed: false
# frozen_string_literal: true

require "test_helper"

class AppContactBehaviorTest < ActiveSupport::TestCase
  test "belongs_to associations exist" do
    behavior = AppContactBehavior.new
    assert_respond_to behavior, :app_contact
    assert_respond_to behavior, :actor
    assert_respond_to behavior, :app_contact_behavior_level
    assert_respond_to behavior, :app_contact_behavior_event
  end

  test "app_contact method returns contact when subject_type matches" do
    skip("Requires AppContact fixtures")
  end

  test "app_contact= method sets subject_id and subject_type" do
    behavior = AppContactBehavior.new
    mock_contact = OpenStruct.new(id: 123)

    behavior.app_contact = mock_contact

    assert_equal 123, behavior.subject_id
    assert_equal "AppContact", behavior.subject_type
  end

  test "validates presence of subject_id" do
    behavior = AppContactBehavior.new(subject_id: nil, subject_type: "Test")
    assert_not behavior.valid?
    assert behavior.errors[:subject_id].any?
  end

  test "validates presence of subject_type" do
    behavior = AppContactBehavior.new(subject_id: 1, subject_type: nil)
    assert_not behavior.valid?
    assert behavior.errors[:subject_type].any?
  end
end
