class MessageRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :message }
end
