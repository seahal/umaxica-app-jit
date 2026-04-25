# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class NotificationActivityLevelTest < ActiveSupport::TestCase
  test "has NOTHING constant" do
    assert_equal 0, NotificationActivityLevel::NOTHING
  end

  test "can load nothing level from db" do
    nothing = NotificationActivityLevel.find(NotificationActivityLevel::NOTHING)

    assert_not_nil nothing
    assert_equal 0, nothing.id
  end

  test "includes all default ids" do
    ids = NotificationActivityLevel.pluck(:id)

    assert_empty(NotificationActivityLevel::DEFAULTS - ids)
  end

  test "restrict_with_error on destroy when activities exist" do
    level = NotificationActivityLevel.find(NotificationActivityLevel::NOTHING)
    NotificationActivity.create!(
      subject_id: 1,
      subject_type: "UserNotification",
      event_id: NotificationActivityEvent::DEVICE_REGISTERED,
      level_id: level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not level.destroy
  end
end
