# frozen_string_literal: true

# == Schema Information
#
# Table name: client_notifications
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
#  index_client_notifications_on_public_id             (public_id) UNIQUE
#  index_client_notifications_on_user_notification_id  (user_notification_id)
#
# Foreign Keys
#
#  fk_client_notifications_on_user_notification_id_cascade  (user_notification_id => user_notifications.id) ON DELETE => cascade
#

class ClientNotification < NotificationRecord
  include ::PublicId

  belongs_to :user_notification, optional: false, inverse_of: :client_notifications
end
