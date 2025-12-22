class NotificationsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :notification, reading: :notification_replica }
end
