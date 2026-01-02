# frozen_string_literal: true

# == Schema Information
#
# Table name: user_notifications
#
#  id         :uuid             not null, primary key
#  user_id    :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_notifications_on_user_id  (user_id)
#

class UserNotification < NotificationRecord
  include ::PublicId

  belongs_to :user, inverse_of: :user_notifications
  has_many :client_notifications,
           inverse_of: :user_notification,
           dependent: :delete_all
end
