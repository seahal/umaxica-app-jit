# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
class NotificationActivityEvent < ActivityRecord
  self.record_timestamps = false
  DEVICE_REGISTERED = 1
  DEVICE_REVOKED = 2
  DEVICE_ROTATED = 3
  WEBPUSH_SUBSCRIPTION_CREATED = 4
  WEBPUSH_SUBSCRIPTION_REVOKED = 5
  IOS_DEVICE_REGISTERED = 6
  IOS_DEVICE_REVOKED = 7
  DELIVERY_TARGET_DISABLED = 8
  DELIVERY_TARGET_ENABLED = 9
  TOKEN_INVALIDATED = 10

  has_many :notification_activities,
           class_name: "NotificationActivity",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :notification_activity_event,
           dependent: :restrict_with_error

  DEFAULTS = [
    DEVICE_REGISTERED,
    DEVICE_REVOKED,
    DEVICE_ROTATED,
    WEBPUSH_SUBSCRIPTION_CREATED,
    WEBPUSH_SUBSCRIPTION_REVOKED,
    IOS_DEVICE_REGISTERED,
    IOS_DEVICE_REVOKED,
    DELIVERY_TARGET_DISABLED,
    DELIVERY_TARGET_ENABLED,
    TOKEN_INVALIDATED,
  ].freeze

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
