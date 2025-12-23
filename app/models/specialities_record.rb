class SpecialitiesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :speciality, reading: :speciality_replica }
end
