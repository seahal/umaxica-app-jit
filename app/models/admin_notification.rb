# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_notifications
# Database name: notification
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  public_id             :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  staff_notification_id :bigint           not null
#
# Indexes
#
#  index_admin_notifications_on_public_id              (public_id) UNIQUE
#  index_admin_notifications_on_staff_notification_id  (staff_notification_id)
#
# Foreign Keys
#
#  fk_admin_notifications_on_staff_notification_id_cascade  (staff_notification_id => staff_notifications.id) ON DELETE => cascade
#

class AdminNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff_notification, optional: false, inverse_of: :admin_notifications
end
