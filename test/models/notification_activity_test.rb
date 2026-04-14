# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activities
# Database name: activity
#
#  id             :bigint           not null, primary key
#  actor_type     :text             default(""), not null
#  context        :jsonb            not null
#  current_value  :text             default(""), not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at    :datetime         not null
#  previous_value :text             default(""), not null
#  subject_type   :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  actor_id       :bigint           default(0), not null
#  event_id       :bigint           default(0), not null
#  level_id       :bigint           default(0), not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_notification_act  (subject_type,subject_id,occurred_at)
#  index_notification_activities_on_actor_id_and_occurred_at    (actor_id,occurred_at)
#  index_notification_activities_on_event_id                    (event_id)
#  index_notification_activities_on_expires_at                  (expires_at)
#  index_notification_activities_on_level_id                    (level_id)
#  index_notification_activities_on_occurred_at                 (occurred_at)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => notification_activity_events.id)
#  fk_rails_...  (level_id => notification_activity_levels.id)
#
require "test_helper"

class NotificationActivityTest < ActiveSupport::TestCase
  fixtures :notification_activity_events, :notification_activity_levels

  setup do
    @event = notification_activity_events(:device_registered)
    @level = notification_activity_levels(:nothing)
  end

  test "uses bigint primary key" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: "UserNotification",
      event_id: @event.id,
      level_id: @level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_predicate activity, :valid?
  end

  test "belongs to notification_activity_event" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: "UserNotification",
      event_id: @event.id,
      level_id: @level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal @event, activity.notification_activity_event
  end

  test "belongs to notification_activity_level" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: "UserNotification",
      event_id: @event.id,
      level_id: @level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal @level, activity.notification_activity_level
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: "UserNotification",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 999_999,
      level_id: @level.id,
    )

    assert_not activity.valid?
    assert_includes activity.errors[:event_id], "must reference an existing notification_activity_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: "UserNotification",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: @event.id,
      level_id: 999_999,
    )

    assert_not activity.valid?
    assert_includes activity.errors[:level_id], "must reference an existing notification_activity_level"
  end

  test "validates presence of subject_id" do
    activity = NotificationActivity.new(
      subject_id: nil,
      subject_type: "UserNotification",
      event_id: @event.id,
      level_id: @level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not activity.valid?
    assert_includes activity.errors[:subject_id], I18n.t("errors.messages.blank")
  end

  test "validates presence of subject_type" do
    activity = NotificationActivity.new(
      subject_id: 1,
      subject_type: nil,
      event_id: @event.id,
      level_id: @level.id,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not activity.valid?
    assert_includes activity.errors[:subject_type], I18n.t("errors.messages.blank")
  end
end
