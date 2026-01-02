# frozen_string_literal: true

# == Schema Information
#
# Table name: client_notifications
#
#  id                   :uuid             not null, primary key
#  public_id            :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  user_notification_id :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_client_notifications_on_user_notification_id  (user_notification_id)
#

class ClientNotification < NotificationRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  belongs_to :user_notification, optional: true, inverse_of: :client_notifications
end
