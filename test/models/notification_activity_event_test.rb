# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class NotificationActivityEventTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 1, NotificationActivityEvent::DEVICE_REGISTERED
    assert_equal 2, NotificationActivityEvent::DEVICE_REVOKED
    assert_equal 3, NotificationActivityEvent::DEVICE_ROTATED
    assert_equal 4, NotificationActivityEvent::WEBPUSH_SUBSCRIPTION_CREATED
    assert_equal 5, NotificationActivityEvent::WEBPUSH_SUBSCRIPTION_REVOKED
    assert_equal 6, NotificationActivityEvent::IOS_DEVICE_REGISTERED
    assert_equal 7, NotificationActivityEvent::IOS_DEVICE_REVOKED
    assert_equal 8, NotificationActivityEvent::DELIVERY_TARGET_DISABLED
    assert_equal 9, NotificationActivityEvent::DELIVERY_TARGET_ENABLED
    assert_equal 10, NotificationActivityEvent::TOKEN_INVALIDATED
  end

  test "includes all default ids" do
    ids = NotificationActivityEvent.pluck(:id)

    assert_empty(NotificationActivityEvent::DEFAULTS - ids)
  end

  test "accepts integer ids" do
    record = NotificationActivityEvent.new(id: NotificationActivityEvent::DEVICE_REGISTERED)

    assert_predicate record, :valid?
  end
end
