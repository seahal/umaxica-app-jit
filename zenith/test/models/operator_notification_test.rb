# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_notifications
# Database name: notification
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  public_id             :string           default(""), not null
#  staff_notification_id :bigint           not null
#
# Indexes
#
#  index_operator_notifications_on_public_id              (public_id) UNIQUE
#  index_operator_notifications_on_staff_notification_id  (staff_notification_id)
#
# Foreign Keys
#
#  fk_admin_notifications_on_staff_notification_id_cascade  (staff_notification_id => staff_notifications.id) ON DELETE => cascade
#
#  fk_admin_notifications_on_staff_notification_id_cascade
#    (staff_notification_id => staff_notifications.id) ON DELETE => cascade
require "test_helper"

class OperatorNotificationTest < ActiveSupport::TestCase
  fixtures :staffs

  test "is valid with a staff notification" do
    record = OperatorNotification.new(staff_notification: build_staff_notification)

    assert_predicate record, :valid?
  end

  test "generates public_id on create" do
    record = OperatorNotification.new(staff_notification: build_staff_notification)

    assert_public_id_generated(record)
  end

  test "is invalid without a staff_notification" do
    record = OperatorNotification.new

    assert_invalid_attribute(record, :staff_notification)
  end

  private

  def build_staff_notification
    StaffNotification.create!(staff: staffs(:one))
  end
end
