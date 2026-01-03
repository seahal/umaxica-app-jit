# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_notifications
#
#  id                    :uuid             not null, primary key
#  public_id             :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  staff_notification_id :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_admin_notifications_on_staff_notification_id  (staff_notification_id)
#

class AdminNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff_notification, optional: true, inverse_of: :admin_notifications
end
