class StaffNotification < NotificationRecord
  include ::PublicId

  belongs_to :staff, optional: true, inverse_of: :staff_notifications
end
