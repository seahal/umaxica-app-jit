# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_notifications
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  staff_id   :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  updated_at :datetime         not null
#

class StaffNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_notifications
end
