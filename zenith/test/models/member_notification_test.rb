# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: member_notifications
# Database name: notification
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :string           default(""), not null
#  user_notification_id :bigint           not null
#
# Indexes
#
#  index_member_notifications_on_public_id             (public_id) UNIQUE
#  index_member_notifications_on_user_notification_id  (user_notification_id)
#
# Foreign Keys
#
#  fk_member_notifications_on_user_notification_id_cascade  (user_notification_id => user_notifications.id) ON DELETE => cascade
#
#  fk_member_notifications_on_user_notification_id_cascade
#    (user_notification_id => user_notifications.id) ON DELETE => cascade
require "test_helper"

class MemberNotificationTest < ActiveSupport::TestCase
  fixtures :users

  test "is valid with a user notification" do
    record = MemberNotification.new(user_notification: build_user_notification)

    assert_predicate record, :valid?
  end

  test "generates public_id on create" do
    record = MemberNotification.new(user_notification: build_user_notification)

    assert_public_id_generated(record)
  end

  test "is invalid without a user_notification" do
    record = MemberNotification.new

    assert_invalid_attribute(record, :user_notification)
  end

  private

  def build_user_notification
    UserNotification.create!(user: users(:one))
  end
end
