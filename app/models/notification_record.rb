class NotificationRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :notification }
end
