class QueuesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :queue, reading: :queue_replica }
end
