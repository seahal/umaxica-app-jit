# frozen_string_literal: true

# == Schema Information
#
# Table name: client_notifications
# Database name: notification
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  user_notification_id :bigint           not null
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

  belongs_to :user_notification, optional: false, inverse_of: :client_notifications
end
