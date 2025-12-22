class BusinessesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :business, reading: :business_replica }
end
