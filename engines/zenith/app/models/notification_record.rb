# typed: false
# frozen_string_literal: true

# Deployment scope: Global
# Shared worldwide. A single database instance serves all regions (jp, us, etc.).
class NotificationRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :notification, reading: :notification_replica }
end
