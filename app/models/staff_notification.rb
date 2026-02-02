# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_notifications
# Database name: notification
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  staff_id   :bigint           not null
#
# Indexes
#
#  index_staff_notifications_on_public_id  (public_id) UNIQUE
#  index_staff_notifications_on_staff_id   (staff_id)
#

class StaffNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff, optional: false, inverse_of: :staff_notifications
  has_many :admin_notifications,
           inverse_of: :staff_notification,
           dependent: :delete_all
end
