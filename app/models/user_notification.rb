# frozen_string_literal: true

# == Schema Information
#
# Table name: user_notifications
# Database name: notification
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string           default(""), not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_notifications_on_public_id  (public_id) UNIQUE
#  index_user_notifications_on_user_id    (user_id)
#

class UserNotification < NotificationRecord
  include ::PublicId

  belongs_to :user, inverse_of: :user_notifications
  has_many :client_notifications,
           inverse_of: :user_notification,
           dependent: :delete_all
end
