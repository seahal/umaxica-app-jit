# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppContactBehaviorEventTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, AppContactBehaviorEvent::NOTHING
    assert_equal 1, AppContactBehaviorEvent::LEGACY_NOTHING
    assert_equal 2, AppContactBehaviorEvent::CREATED
    assert_equal 3, AppContactBehaviorEvent::UPDATED
    assert_equal 4, AppContactBehaviorEvent::DELETED
  end

  test "can load nothing status from db" do
    status = AppContactBehaviorEvent.find(AppContactBehaviorEvent::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppContactBehaviorEvent.count" do
      AppContactBehaviorEvent.ensure_defaults!
    end
  end
end
