# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineBehaviorEventTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, AppTimelineBehaviorEvent::NOTHING
    assert_equal 1, AppTimelineBehaviorEvent::LEGACY_NOTHING
    assert_equal 2, AppTimelineBehaviorEvent::CREATED
    assert_equal 3, AppTimelineBehaviorEvent::UPDATED
    assert_equal 4, AppTimelineBehaviorEvent::DELETED
  end

  test "can load nothing status from db" do
    status = AppTimelineBehaviorEvent.find(AppTimelineBehaviorEvent::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppTimelineBehaviorEvent.count" do
      AppTimelineBehaviorEvent.ensure_defaults!
    end
  end

  test "accepts integer ids" do
    record = AppTimelineBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end
end
