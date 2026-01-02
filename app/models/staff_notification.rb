# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_notifications
#
#  id         :uuid             not null, primary key
#  staff_id   :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staff_notifications_on_staff_id  (staff_id)
#

class StaffNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_notifications
  has_many :admin_notifications,
           inverse_of: :staff_notification,
           dependent: :delete_all
end
