# typed: false
# frozen_string_literal: true

class NotificationRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :notification, reading: :notification_replica }
end
