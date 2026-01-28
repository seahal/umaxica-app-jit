# frozen_string_literal: true

# == Schema Information
#
# Table name: client_notifications
# Database name: notification
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  user_notification_id :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#
# Indexes
#
#  index_client_notifications_on_user_notification_id  (user_notification_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_notification_id => user_notifications.id)
#

class ClientNotification < NotificationRecord
  include ::PublicId

  belongs_to :user_notification, optional: true, inverse_of: :client_notifications
end
