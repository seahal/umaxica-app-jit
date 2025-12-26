class TimelineRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :timeline, reading: :timeline }
end
