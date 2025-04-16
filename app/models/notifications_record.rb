# frozen_string_literal: true

class NotificationsRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :notification, reading: :notification_replica }
end
